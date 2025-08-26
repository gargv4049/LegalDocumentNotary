;; LegalDocument Notary Contract
;; A blockchain notarization service for legal documents with timestamp verification

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-document-exists (err u101))
(define-constant err-document-not-found (err u102))
(define-constant err-invalid-hash (err u103))

;; Data structures
(define-map notarized-documents 
  (buff 32) ;; document hash (SHA-256)
  {
    notary: principal,
    timestamp: uint,
    block-height: uint,
    document-title: (string-ascii 100)
  })

(define-data-var total-notarized uint u0)

;; Function 1: Notarize a legal document
(define-public (notarize-document (document-hash (buff 32)) (document-title (string-ascii 100)))
  (begin
    ;; Ensure document hash is valid (32 bytes)
    (asserts! (is-eq (len document-hash) u32) err-invalid-hash)
    
    ;; Check if document is already notarized
    (asserts! (is-none (map-get? notarized-documents document-hash)) err-document-exists)
    
    ;; Store the notarized document with timestamp and block height
    (map-set notarized-documents 
      document-hash
      {
        notary: tx-sender,
        timestamp: stacks-block-height,
        block-height: stacks-block-height,
        document-title: document-title
      })
    
    ;; Increment total notarized count
    (var-set total-notarized (+ (var-get total-notarized) u1))
    
    ;; Print event for indexing
    (print {
      event: "document-notarized",
    
      notary: tx-sender,
      timestamp: stacks-block-height,
      block-height: stacks-block-height,
      document-title: document-title
    })
    
    (ok {
      notarized: true,
      timestamp: stacks-block-height,
      block-height: stacks-block-height
    })))


;; Read-only function to get total notarized documents
(define-read-only (get-total-notarized)
  (ok (var-get total-notarized)))