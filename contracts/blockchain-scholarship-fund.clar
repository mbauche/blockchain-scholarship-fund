;; title: blockchain-scholarship-fund
;; version:
;; summary:
;; description:

;; ---------------------------------------------------------
;; Decentralized Scholarship Fund (DSF) Smart Contract
;; ---------------------------------------------------------
;; Core Features:
;; - Donors contribute STX into the scholarship pool
;; - Students apply with metadata
;; - Committee/DAO voters vote for applicants
;; - Admin (or DAO) awards scholarships to selected applicants
;; - Fully transparent donations, applications, votes, and awards
;; ---------------------------------------------------------

;; -------------------------
;; DATA STRUCTURES & STATE
;; -------------------------

(define-map donors {account: principal} {amount: uint})
(define-map applicants {id: uint} 
    {student: principal, metadata: (string-ascii 256), votes: uint, awarded: bool})
(define-map votes {voter: principal, app-id: uint} {casted: bool})

(define-data-var total-donations uint u0)
(define-data-var next-applicant-id uint u1)
(define-data-var scholarship-pool uint u0)

(define-constant contract-owner tx-sender)

;; -------------------------
;; DONATION FUNCTIONS
;; -------------------------

(define-public (donate (amount uint))
    (begin
        (asserts! (> amount u0) (err "Donation amount must be greater than zero"))
        (unwrap! (stx-transfer? amount tx-sender contract-owner) (err "STX transfer failed"))
        (let ((prev-donation (default-to u0 (get amount (map-get? donors {account: tx-sender})))))
            (map-set donors {account: tx-sender} {amount: (+ prev-donation amount)}))
        (var-set total-donations (+ (var-get total-donations) amount))
        (var-set scholarship-pool (+ (var-get scholarship-pool) amount))
        (ok true)
    )
)

;; -------------------------
;; APPLICATION FUNCTIONS
;; -------------------------

(define-public (apply-scholarship (metadata (string-ascii 256)))
    (let ((app-id (var-get next-applicant-id)))
        (map-set applicants {id: app-id} 
            {student: tx-sender, metadata: metadata, votes: u0, awarded: false})
        (var-set next-applicant-id (+ app-id u1))
        (ok app-id)
    )
)

;; -------------------------
;; VOTING FUNCTIONS
;; -------------------------

(define-public (vote (app-id uint))
    (begin
        (asserts! (is-none (map-get? votes {voter: tx-sender, app-id: app-id})) (err "You have already voted for this applicant"))
        (let ((applicant (map-get? applicants {id: app-id})))
            (asserts! (is-some applicant) (err "Invalid applicant ID"))
            (let ((applicant-data (unwrap-panic applicant)))
                (map-set votes {voter: tx-sender, app-id: app-id} {casted: true})
                (map-set applicants {id: app-id}
                    (merge applicant-data {votes: (+ (get votes applicant-data) u1)}))
                (ok true)
            )
        )
    )
)

;; -------------------------
;; AWARD / DISBURSEMENT
;; -------------------------

(define-public (award-scholarship (app-id uint) (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err "Only owner can award"))
        (let ((applicant (map-get? applicants {id: app-id})))
            (asserts! (is-some applicant) (err "Invalid applicant ID"))
            (asserts! (>= (var-get scholarship-pool) amount) (err "Not enough funds"))
            ;; Transfer STX to student
            (unwrap! (stx-transfer? amount contract-owner (get student (unwrap-panic applicant))) (err "STX transfer failed"))
            (var-set scholarship-pool (- (var-get scholarship-pool) amount))
            ;; Mark applicant as awarded
            (map-set applicants {id: app-id}
                {student: (get student (unwrap-panic applicant)),
                 metadata: (get metadata (unwrap-panic applicant)),
                 votes: (get votes (unwrap-panic applicant)),
                 awarded: true})
            (ok true)
        )
    )
)

;; -------------------------
;; READ-ONLY FUNCTIONS
;; -------------------------

(define-read-only (get-donations (addr principal))
    (default-to u0 (get amount (map-get? donors {account: addr})))
)

(define-read-only (get-applicant (app-id uint))
    (map-get? applicants {id: app-id})
)

(define-read-only (get-total-pool)
    (var-get scholarship-pool)
)

