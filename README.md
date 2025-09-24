 Decentralized Scholarship Fund Smart Contract 🎓

A Clarity-based smart contract on the Stacks blockchain for managing **scholarship donations, student applications, voting, and transparent disbursement of funds**.  
This project demonstrates how blockchain technology can support **fair, transparent, and auditable educational funding**.

---

 Features
- **Donations**  
  - Donors contribute STX to the scholarship pool.  
  - All contributions are tracked transparently on-chain.  

- **Applications**  
  - Students can apply with metadata (e.g., ID hash, GPA link, or document reference).  
  - Each applicant is assigned a unique application ID.  

- **Voting**  
  - Committee members (or DAO participants) can vote on applicants.  
  - One vote per voter per applicant.  

- **Disbursement**  
  - Scholarships awarded by contract owner (can be extended to DAO governance).  
  - STX funds automatically transferred to awarded student’s wallet.  

- **Transparency & Auditability**  
  - Anyone can query donations, applicants, votes, and total pool balance.  

---

 Contract Structure
- **Donors Map** → Tracks donations by address.  
- **Applicants Map** → Stores applicant data (ID, wallet, metadata, votes, award status).  
- **Votes Map** → Ensures no double-voting.  
- **Scholarship Pool** → Stores total funds available for distribution.  

---

 Functions

 Public Functions
- `donate(amount)` → Contribute STX to the pool.  
- `apply-scholarship(metadata)` → Submit a scholarship application.  
- `vote(app-id)` → Vote for a specific applicant.  
- `award-scholarship(app-id, amount)` → Award funds to a student (admin only).  

 Read-Only Functions
- `get-donations(addr)` → View donations from a specific donor.  
- `get-applicant(app-id)` → Retrieve applicant details.  
- `get-total-pool()` → Check current scholarship pool balance.  

---

 Deployment
1. Clone this repository.  
2. Install [Clarinet](https://docs.hiro.so/clarinet/intro) for local Stacks development.  
3. Deploy contract locally with:  
   ```bash
   clarinet console
