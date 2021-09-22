(in-package :mu-cl-resources)

(define-resource company ()
  :class         (s-prefix "au:Company")
  :properties    `((:name        :string ,(s-prefix "foaf:name"))
                   (:description :string ,(s-prefix "au:description"))
                   (:vatnumber   :string ,(s-prefix "au:VATnumber"))
                   (:address     :string ,(s-prefix "au:address")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "company")

(define-resource category ()
  :class         (s-prefix "au:Category")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :has-one       `((category :via ,(s-prefix "au:parentCategory")
                             :as "parentcategory"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "categories")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Classes as data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource classinfo ()
  :class         (s-prefix "owl:Class")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "classinfo")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Condition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource condition ()
  :class         (s-prefix "au:ProductCondition")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "condition")

(define-resource new (condition)
  :class         (s-prefix "au:New")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "new")

(define-resource old (condition)
  :class         (s-prefix "au:Old")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "old")

(define-resource used (condition)
  :class         (s-prefix "au:Used")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "used")

(define-resource brandnew (new)
  :class         (s-prefix "au:BrandNew")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "brandnew")

(define-resource damagedpackaging (new)
  :class         (s-prefix "au:DamagedPackaging")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "damagedpackaging")

(define-resource aged (old)
  :class         (s-prefix "au:Aged")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "aged")

(define-resource damaged (old)
  :class         (s-prefix "au:Damaged")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "damaged")

(define-resource excellent (old)
  :class         (s-prefix "au:Excellent")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "excellent")

(define-resource broken (used)
  :class         (s-prefix "au:Broken")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "broken")

(define-resource good (used)
  :class         (s-prefix "au:Good")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "good")

(define-resource wornout (used)
  :class         (s-prefix "au:WornOut")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "wornout")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reason
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource reason ()
  :class         (s-prefix "au:ReasonForAuction")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "reason")

(define-resource excess (reason)
  :class         (s-prefix "au:Excess")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "excess")

(define-resource expiration (reason)
  :class         (s-prefix "au:Expiration")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "expiration")

(define-resource goodcause (reason)
  :class         (s-prefix "au:GoodCause")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "goodcause")

(define-resource judicial (reason)
  :class         (s-prefix "au:Judicial")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "judicial")

(define-resource stunt (reason)
  :class         (s-prefix "au:Stunt")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "stunt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Users
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource user ()
  :class         (s-prefix "au:User")
  :properties    `((:email    :string ,(s-prefix "au:email"))
                   (:language :string ,(s-prefix "au:language"))
                   (:timezone :string ,(s-prefix "au:timezone")))
  :has-many      `((account   :via    ,(s-prefix "foaf:account")
                              :as     "accounts"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "users")

(define-resource participant (user)
  :class         (s-prefix "au:Participant")
  :properties    `((:firstname :string ,(s-prefix "foaf:firstName"))
                   (:lastname  :string ,(s-prefix "foaf:lastName"))
                   (:address   :string ,(s-prefix "au:address"))
                   (:vatnumber :string ,(s-prefix "au:VATNumber"))
                   (:balance   :number ,(s-prefix "au:balance")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "participants")

(define-resource seller (participant)
  :class         (s-prefix "au:Seller")
  :has-one       `((company :via ,(s-prefix "au:forCompany")
                            :as  "company"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "sellers")

(define-resource client (participant)
  :class         (s-prefix "au:Client")
  :has-many      `((lot :via ,(s-prefix "au:hasFavorite")
                        :as  "favorites"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "clients")

(define-resource support (user)
  :class         (s-prefix "au:Support")
  :properties    `((:username :string ,(s-prefix "foaf:nick")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "supporters")

(define-resource administrator (support)
  :class         (s-prefix "au:Administrator")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "administrators")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bid
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource bid ()
  :class         (s-prefix "au:Bid")
  :properties    `((:amount    :number   ,(s-prefix "au:bidAmount"))
                   (:timestamp :datetime ,(s-prefix "au:timeStamp")))
  :has-one       `((client :via ,(s-prefix "au:byUser")
                           :as  "user")
                   (lot    :via ,(s-prefix "au:hasBid")
                           :inverse t
                           :as "lot"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "bids")

(define-resource secretbid (bid)
  :class         (s-prefix "au:SecretBid")
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "secretbids")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource lot ()
  :class         (s-prefix "au:Lot")
  :properties    `((:subject         :string     ,(s-prefix "au:subject"))
                   (:description     :string     ,(s-prefix "au:description"))
                   (:amountofobjects :number     ,(s-prefix "au:amountOfObject"))
                   (:productvat      :number     ,(s-prefix "au:productVAT"))
                   (:auctiontax      :number     ,(s-prefix "au:auctionTax"))
                   (:vatonauctiontax :number     ,(s-prefix "au:VATonAuctionTax"))
                   (:enddate         :datetime   ,(s-prefix "au:endDateTime"))
                   (:enddateiso      :datetime   ,(s-prefix "au:endDateTime"))
                   (:startamount     :number     ,(s-prefix "au:startAmount"))
                   (:stepamount      :number     ,(s-prefix "au:stepAmount")))
  :has-many      `((bid       :via ,(s-prefix "au:hasBid")
                              :as  "bids"))
  :has-one       `((condition :via ,(s-prefix "au:condition")
                              :as  "condition")
                   (category  :via ,(s-prefix "au:inCategory")
                              :as  "category")
                   (classinfo :via ,(s-prefix "rdf:type")
                              :as  "classinfo")
                   (auction   :via ,(s-prefix "au:hasLot")
                              :inverse t
                              :as  "auction"))
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "lots")

(define-resource absolutelot (lot)
  :class         (s-prefix "au:AbsoluteAuctionLot")
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "absolutelots")

(define-resource fixedtimelot (absolutelot)
  :class         (s-prefix "au:FixedTimeAuctionLot")
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "fixedtimelots")

(define-resource prolongedtimelot (absolutelot)
  :class         (s-prefix "au:ProlongedTimeAuctionLot")
  :properties    `((:incrementtime :number ,(s-prefix "au:incrementTime")))
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "prolongedtimelots")

(define-resource minimumbidlot (lot)
  :class         (s-prefix "au:MinimumBidAuctionLot")
  :properties    `((:minimumsellingamount :number ,(s-prefix "au:minimumSellingAmount")))
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "minimumbidlots")

(define-resource reservelot (lot)
  :class         (s-prefix "au:ReserveAuctionLot")
  :properties    `((:secrettargetamount :number ,(s-prefix "au:secretTargetAmount")))
  :has-many      `((secretbid :via ,(s-prefix "au:secretBid")
                              :as  "secretbids"))
  :resource-base (s-url "http://redpencil.io/Auctions")
  :on-path       "reservelots")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auctions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource auction ()
  :class         (s-prefix "au:Auction")
  :properties    `((:subject         :string   ,(s-prefix "au:subject"))
                   (:description     :string   ,(s-prefix "au:description"))
                   (:startdate       :datetime ,(s-prefix "au:startDateTime"))
                   (:enddate         :datetime ,(s-prefix "au:endDateTime"))
                   (:takeawayaddress :string   ,(s-prefix "au:takeAwayAddress"))
                   (:takeawaydate    :datetime ,(s-prefix "au:takeAwayDateTime"))
                   (:visitDate       :datetime ,(s-prefix "au:visitDateTime")))
  :has-one       `((company  :via ,(s-prefix "au:organisedByCompany")
                             :as  "organisingcompany")
                   (company  :via ,(s-prefix "au:sellingCompany")
                             :as  "sellingcompany")
                   (seller   :via ,(s-prefix "au:sellingParticipant")
                             :as  "sellingparticipant")
                   (reason   :via ,(s-prefix "au:reason")
                             :as  "reason"))
  :has-many      `((category :via ,(s-prefix "au:inCategory")
                             :as  "categories")
                   (lot      :via ,(s-prefix "au:hasLot")
                             :as  "lots"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "auctions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Account
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-resource account ()
  :class         (s-prefix "foaf:OnlineAccount")
  :properties    `((:username :string ,(s-prefix "foaf:accountName")))
  :has-one       `((user :via ,(s-prefix "foaf:account")
                         :inverse t
                         :as "user"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "accounts")

(run-validations)

