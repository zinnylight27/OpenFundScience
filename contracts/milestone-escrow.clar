;; OpenFundScience - Milestone Escrow Contract (Clarity v2)

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-NO-FUNDING u101)
(define-constant ERR-INVALID-MILESTONE u102)
(define-constant ERR-ALREADY-CLAIMED u103)
(define-constant ERR-NOT-VALIDATOR u104)
(define-constant ERR-NOT-RESEARCHER u105)
(define-constant ERR-NOT-READY u106)

(define-data-var admin principal tx-sender)

(define-map projects
  uint
  {
    researcher: principal,
    total-funding: uint,
    milestones: uint,
    validated: uint,
    released: uint
  }
)

(define-map milestone-approvals
  { project-id: uint, milestone-id: uint }
  bool
)

(define-map contributions
  { project-id: uint, contributor: principal }
  uint
)

(define-map validators
  { project-id: uint, milestone-id: uint, validator: principal }
  bool
)

(define-map claimed
  { project-id: uint, milestone-id: uint }
  bool
)

;; Admin creates a project with a set number of milestones
(define-public (create-project (id uint) (researcher principal) (milestones uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set projects id {
      researcher: researcher,
      total-funding: u0,
      milestones: milestones,
      validated: u0,
      released: u0
    })
    (ok true)
  )
)

;; Contributors can send STX to fund the project
(define-public (contribute (project-id uint))
  (let (
    (project-opt (map-get? projects project-id))
    (amount (stx-get-transfer-amount))
  )
    (if (is-some project-opt)
        (let (
          (project (unwrap! project-opt (err ERR-NO-FUNDING)))
          (existing (default-to u0 (map-get? contributions { project-id: project-id, contributor: tx-sender })))
        )
          (asserts! (> amount u0) (err ERR-NO-FUNDING))
          (map-set contributions { project-id: project-id, contributor: tx-sender } (+ existing amount))
          (map-set projects project-id (merge project { total-funding: (+ (get total-funding project) amount) }))
          (ok true)
        )
        (err ERR-NO-FUNDING)
    )
  )
)

;; Admin assigns validators for a given milestone
(define-public (assign-validator (project-id uint) (milestone-id uint) (validator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (map-set validators { project-id: project-id, milestone-id: milestone-id, validator: validator } true)
    (ok true)
  )
)

;; Validator approves a milestone
(define-public (approve-milestone (project-id uint) (milestone-id uint))
  (let (
    (approval-key { project-id: project-id, milestone-id: milestone-id })
    (validator-key { project-id: project-id, milestone-id: milestone-id, validator: tx-sender })
    (is-validator (default-to false (map-get? validators validator-key)))
  )
    (begin
      (asserts! is-validator (err ERR-NOT-VALIDATOR))
      (asserts! (not (default-to false (map-get? milestone-approvals approval-key))) (err ERR-ALREADY-CLAIMED))

      ;; update project validated count
      (let ((project (unwrap! (map-get? projects project-id) (err ERR-NO-FUNDING))))
        (map-set milestone-approvals approval-key true)
        (map-set projects project-id (merge project {
          validated: (+ (get validated project) u1)
        }))
        (ok true)
      )
    )
  )
)

;; Researcher claims funding after milestone approved
(define-public (claim-milestone (project-id uint) (milestone-id uint))
  (let (
    (project (unwrap! (map-get? projects project-id) (err ERR-NO-FUNDING)))
    (approval-key { project-id: project-id, milestone-id: milestone-id })
    (claimed-key { project-id: project-id, milestone-id: milestone-id })
  )
    (begin
      (asserts! (is-eq tx-sender (get researcher project)) (err ERR-NOT-RESEARCHER))
      (asserts! (default-to false (map-get? milestone-approvals approval-key)) (err ERR-NOT-READY))
      (asserts! (not (default-to false (map-get? claimed claimed-key))) (err ERR-ALREADY-CLAIMED))

      ;; transfer funds based on milestone
      (let ((per-milestone (/ (get total-funding project) (get milestones project))))
        (map-set claimed claimed-key true)
        (map-set projects project-id (merge project { released: (+ (get released project) per-milestone) }))
        (stx-transfer? per-milestone (var-get admin) tx-sender)
      )
    )
  )
)

;; Read-only function to get project metadata
(define-read-only (get-project (id uint))
  (match (map-get? projects id)
    (some project) (ok project)
    (none) (err ERR-NO-FUNDING)
  )
)

;; Read-only milestone approval check
(define-read-only (get-approval (project-id uint) (milestone-id uint))
  (ok (default-to false (map-get? milestone-approvals { project-id: project-id, milestone-id: milestone-id })))
)
