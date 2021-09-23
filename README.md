#  Startup playground app in mu.semte.ch microservice architecture stack

As part of my entry into RedPencil.io, I made a small webapp as a playground for the various microservices available from mu.semte.ch to help me learn and understand the concepts of a microservice architecture and how Linked Data can be used with it. These are my personal notes on a few topics that stood out to me.

## Introduction

This webapp is about auctions. Companies or individual sellers put a number of items, called lots, up for sale through the website. Clients can use the website to browse through the auctions and lots, and once logged in, can mark favorites and place bids on lots.

This is a playground webapplication and is not a finished product. A lot of features have various levels of implementation. Some features are not implemented at all yet. A lot of rules are also not implemented, e.g. when a lot expires, the client with the highest bid should win the lot, but none of this logic works yet.

## Framework and layout

The application is written in JavaScript with Ember.js.

To quickly get started building a (prototyping) webapp, I used Bootstrap 5, a layout framework. It's relatively light and generic, so it gives a lot of freedom. The reason for going to such layout framework is that I did not want to spend much time building my own, but also to see how it is to use a layout framework in Ember.

## Used services and libraries

The mu.semte.ch microservices used in this playground are:

*	mu-authorization
*	mu-migrations-service
*	mu-cl-resources
*	mu-login-service
*	mu-dispatcher
*	mu-identifier
*	mu-delta-notifier
*	mu-javascript-template (to make my own mock-access)

I used the Virtuoso Docker image from Tenforce and I also made a Docker container for serving the Ember app (development with live reload), and put this behind the mu-dispatcher so everything is nicely contained.

Some libraries I used for this app are: ember-render-modifiers and ember-mu-login.

*Note on Docker containers: one of my development systems uses SE-Linux and this blocks write access to Docker volumes. I used `Z` on each volume to allow the proper tagging of the volume.*

## Ontology engineering

Before starting on the webapp, I took some time to develop an ontology. I used Protégé for this, because I'm not used to creating ontologies by hand yet. A tool like Protégé lets you play with it a bit more, and check for logical errors using a reasoner (HermiT).

A lot of properties are defined in the ontology itself, instead of relying on external ontologies. The reason for this is that I found it hard to search through existing ontologies for the exact property I needed. Defining your own works, and is very easy, but this defeats the purpose of using linked data.

During ontology engineering I also defined test data (individuals) in a different ontology namespace. Having some examples helps to check if the model is consistent and sound, but also helps to populate an otherwise blank webapp with some nice mock data. Because the data is defined in a different namespace, it is logically separated from the ontology, is handled in different files and can be uploaded to the database separately (or not at all during production).

There are also individuals defined in the main ontology. These are part of the ontology itself and are mostly used to attach some form of typing information to other individuals. E.g. `au:BrandNewCondition` is an individual that is used as object of the `au:condition` property to indicate that an individual representing an actual product for sale is in very good condition. More on this in later chapters.

### Prefixes

The following prefixes are used for this ontology, and used to refer to properties and classes from different ontologies:

| Prefix  | URI                                               |
|---------|---------------------------------------------------|
| au      | http://www.semanticweb.org/ben/ontologies/auction |
| aud     | http://www.semanticweb.org/ben/data/auction       |
| foaf    | http://xmlns.com/foaf/0.1/                        |
| session | http://mu.semte.ch/vocabularies/session/          |
| account | http://mu.semte.ch/vocabularies/account/          |
| migr    | http://mu.semte.ch/vocabularies/migrations/       |

As you can see, this list is rather short. Replacements are needed for (e.g.) addresses, prices, valuta, &hellip;

### Classes

The following classes are defined (`owl:Class`) in the ontology:

*	Auction
*	Bid
	*	SecretBid
*	Category
*	Company
*	Lot
	*	AbsoluteAuctionLot
		*	FixedTimeAuctionLot
		*	ProlongedTimeAuctionLot
	*	MinimumBidAuctionLot
	*	ReserveAuctionLot
*	ProductCondition
	*	New
		*	BrandNew
		*	DamagedPackaging
	*	Old
		*	Aged
		*	Damaged
		*	Excellent
	*	Used
		*	Broken
		*	Good
		*	WornOut
*	ReasonForAuction
	*	Excess
	*	Expiration
	*	GoodCause
	*	Judicial
	*	Stunt
*	User
	*	Participant
		*	Client
		*	Seller
	*	Support
		*	Administrator

The following classes are defined in the ontology using OWL with constraints, but are not used elsewere. This is because you need some form of reasoning to be able to find class definitions and superclass definitions on individuals that use OWL constraints.

*	**BigAuction** (an auction with at least 5 lots (e.g.))
*	**AbsoluteExpensiveAutionLot** (a lot that starts with a high price)
*	**RelativeExpensiveAuctionLot** (a lot that has come up to a high price due to excessive bidding)
*	**ExcellentAntique** (a lot that is old but in excellent condition)
*	**PopularLot** (a lot with at least 10 bids)
*	**ValuedAntique** (a lot that has aged)

### Inheritance

As can be seen in the previous two listings, there is a lot of inheritance (indicated by sublisting). Individuals of subclasses inherit properties of their superclasses becuase these individuals are more specific forms of their superclass definition. Inheritance is indicated with the `owl:subClassOf` property. RDF adheres to the open world assumption, which means that you could use any property on any individual (given that domains and ranges are not contradicting) or even fabricate a new property on the spot, and yet, using inheritance is still a nice way to group individuals and to logically classify them based on their nature. For example: a child is still a human person, so Child is a subclass of Person. It is possible to use Child as a class without the relation to the Person class, because you can just use some properties on individuals of the Child class, but knowing that there is a subclass relation provides useful information for reasoning and as a mental model.

Having the inheritance is also useful when mapping these individuals into a more strict relational model like JSON and JavaScript objects as is done in the mu-cl-resources service and the webapp. There, you get actual property (and method) inheritance.

### Attaching types to individuals

In the auction application, there exist three mechanisms for typing individuals. Typing an individual means to give some tag to it such that individuals can be grouped, filtered, &hellip; by this piece of information. These three mechanisms where experimented with to see wich one is better in which situation. The following is an explanation.

The mechanism for typing you would use in regular RDF would be to refer to a URI of a class as the object of a relation, just like you would when specifying `owl:subClassOf` or `rdf:type`. It is possible to extract information about classes and properties through mu-cl-resources as you would with normal individuals. Class definitions are also just individuals. However this is less intuative, so three different mechanisms were experimented with here.

The first experiment was to make a single individual per (very specific) subclass as a singleton. This mechanism can be observed in `au:ProductCondition` and its subclasses. Every leaf node in the subclass tree has just one individual, and this individual is addressed as object in a typing relation. For example: there is the class tree `ProductCondition > New > BrandNew` and this `BrandNew` class has just one singleton individual, namely `NewBrandNewCondition`, that is used to specify that a product is in mint condition: `aud:someProduct au:condition au:NewBrandNewCondition`. Note that products are defined as data in a separate ontology (aud) and that the individuals for typing are defined in the main ontology (au) because they are more part of the definitions than the data descriptions. Probably the biggest disadvantage to this approach is that the types of product conditions are rather fixed. When a new subclass is needed, the ontology needs to be updated. Ideally, the ontology never needs any changes because it should be well thought out from the beginning. When the types of subclasses is exhaustive and will never need changing, this approach could be viable. The `ProductCondition`s `New`, `Used`, `Old` and their subclasses, for example, will probably suffice in the long run.

The second approach, as observed with the `au:ReasonForAuction`, is a bit more dynamic. Its subclasses are more generic. `ReasonForAcution` defines why an auction is taking place. Every one of these subclasses have more than one distinct singleton individuals to express more specific meanings. The reason `Excess` (to indicate that an auction takes places because of some stock issues), for example, has individuals `Leftover` and `TooMuchOrdered` which both describe a more specific meaning of excessiveness. This is somewhat of a middel ground approach. The subclasses represent main categories and the individuals represent very specific applications of the category. This addresses the biggest disadvantage of the previous approach: the main categories of types are now still static because they belong the ontology, but they are exhaustive and generic enough for new individuals as concrete subtypes to be created at will during the lifespan of the ontology and its use in the application. A new concrete subtype can be created as data whenever you want without changing the ontology.

The third approach is the most dynamic. This approach can be seen with the `au:Category`, that simply has no subclasses. Every individual of a category can have some information about the category and a parent category. This effectively rebuilds the sort of infrastucture that was put in place with `owl:subClassOf`, but explicitely inside this ontology. This way, individuals of this class are linked like class definitions would be in OWL, and instead of relying on the perception of class definitions in our ontology as data to be configured in data retreival services like mu-cl-resources, we can rely on the data being available as actual instances of classes defined in our ontology. For example: an instance of `au:Category` could be `aud:RealEstate` that could be used as typing information on other individuals, and used as a parent to more specific types like `Private`, `Industrial`, &hellip; The main disadvantage is that typing information is now fully defined as data instead of being visible in the ontology itself, but it is in general a more dynamic approach. Whole new trees of types can be create whenever needed in the application. When applying this approach (and the previous one as well), you could define some premade categories of types in the ontology that are loaded as initial data into the database, ready to be used in the application.

#### Considerations with relation to mu-cl-resource of attaching types

Choosing between the strategies depends on the needs of the domain. When only a couple of types will ever need to exist, the first and second approach are feasable because they are the easiest to implement and understand, but in general, the last approach is the best option. New types can be invented ad hoc if the need exists and you can keep data away from the resource definitions in the ontology. There are some further consideration however.

In the first and second approach (the creation of one or more singleton individuals per subclass), you have a lot of configuration to do in mu-cl-resources. Every class and subclass of the typing mechanism needs to be addressed in the configuration and they need to inherit properly from each other. For example, to fully configure for the `au:ProductCondition` from the first approach, there are 12 resource definitions. For the example in the second approach, there are only 6 resource definitions, because you can separate on individuals of the same class instead. Defining all typing information as data, as in the third approach, results in only a single resource definition and has no inheritance as there is only really one class definition in the ontology.

Also in the first and second approach, the individuals are stub object when used in the application. They usually only contain some literal data and no relations to other individuals. In the web application, this means you should load these object as [read-only nested data](https://guides.emberjs.com/release/models/relationships/#toc_readonly-nested-data). This luckily reduces extraneous code.

With the third approach, the individuals might be deeply nested. The problem becomes how to retreive all these objects with mu-cl-resources from the webapp. When you normally retreive nested data, you would use the `include` query parameter and the name of the property that needs to be included. You could recursively define inclusions, but for some chains, you simply do not now the recursion depth. There is no good solution to this yet (that I am aware of). The way this was solved was to simply get all the individuals of the same class (which is easy because they *are* of the same class, just linked together to form a recursive chain) and to sort out the tree structure in the client code, manual style, in places like a controller. This is actually not that difficult, and since there are realistically not more than a few dozen of types, the amount of data overhead is relatively small.

### Direction of relations

During creation of the ontology, you define relations between individuals or between individuals and literals. These relations are optional and you can also define multiple per individual. Typical one-to-many relations can be defined in RDF on either end of the relation or on both ends. The same applies to many-to-many relations. This gives a lot of freedom, but can sometimes be a little difficult to maintain. Imagine a scenario where you define a one-to-many relation between an auction and multiple lots. Do you define the `hasLot` on the auction or the `belongsToAuction` on the lot? What about a many-to-many relation such as between sellers and lots? You could only define the relations on the seller side for example, making sure the mu-cl-resources uses the correct relation in the correct direction. In RDF, you can define two relations as inverse relations, but in data, you practically only define these once, so you need a convention to always use the same property in the same direction. Because the mu-cl-resources can be configured with has-one and has-many relations, the cleanest way is to define one-to-many relations on the one-side in the data. This way you only deal with 'has-many' to map one-to-many relations in the mu-cl-resources. It is possible to define the relation on both ends in the mu-cl-resources config, either by using inverse relations or by referring to properties that are each others inverse. As for many-to-many relations and one-to-one relations, I prefer to define the relation on the individual that already has the most properties defined or is most likely to change. For example: a lot can have multiple categories, and a category can belong to multiple lots. In this case you would only define the relation `inCategory` on the lot, because the category is not likely to change as it is more of a static individual. In the mu-cl-resources however, you can write the has-many on both sides of the relation, usually with `:inverse t` on one side, so both sides use the same underlying property in the same direction.

## Configuring mu-cl-resources

The mu-cl-recource microservice is configured with a `domain.lisp` and `repository.lisp` file. Configuration can also be made in JSON format, but the Lisp format is much nicer (for me at least). When the ontology uses inheritance, mu-cl-resources reflects that by supplying superclass resources as argument to the `define-resource` macro. Sub-resources automatically inherit the properties from the parent-resource. These properties are automatically looked up in the database and formatted into JSON as expected.

The following code snippet shows a part of the mu-cl-resources configuration.

```lisp
(define-resource lot ()
  :class         (s-prefix "au:Lot")
  :properties    `((:subject         :string     ,(s-prefix "au:subject"))
                   (:description     :string     ,(s-prefix "au:description"))
                   (:amountofobjects :number     ,(s-prefix "au:amountOfObject")))
;                  (  --- omitted properties --- )
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
```

The `absolutelot` resource inherits from the `lot` resource, so the `absolutelot` also has the `subject`, `description`, `amountofobjects`, and other properties as well as the `bid`, `condition`, `category`, `classinfo` and `auction` related objects. The mu-cl-resources service loads these automagically if the proper `include` query parameter is given in case of the wanted related objects.

The lot has many bids, implying a one-to-many relation, and the RDF relation is defined on the lot. In this configuration, the lot as well as the bid resource have a definition for this relation, both using the `au:hasBid` property, but inversed on the bid side.

```lisp
(define-resource category ()
  :class         (s-prefix "au:Category")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :has-one       `((category :via ,(s-prefix "au:parentCategory")
                             :as  "parentcategory"))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "categories")
```

The above code snippet shows the special Category resource that uses the third approach as described in a previous chapter. The only special thing about this resource is that it references itself in one of the related resources under the name `parentcategory`. Mu-cl-resources will load the parent category when you include it as a query parameter, but the parent category chain depth is unpredictable, so mileage may vary in case of nested includes.

On certain pages of the webapp, more information on a specific object's identity is given. This information comes from the class definitions themselves. Classes have an `rdfs:label` and `rdfs:comment` which provide useful information about the nature of the object. Retreiving this information involves configuring mu-cl-resources to also read out the RDFS and OWL properties of objects. This is demonstrated in the following snippet. It is fun to see how easy it is to blur the lines between data and class definitions.

```lisp
(define-resource classinfo ()
  :class         (s-prefix "owl:Class")
  :properties    `((:label   :string ,(s-prefix "rdfs:label"))
                   (:comment :string ,(s-prefix "rdfs:comment")))
  :resource-base (s-url "http://redpencil.io/Auction")
  :on-path       "classinfo")
```

This mechanism is used to provide information on the auction rules per lot. A button shows a popup that gives the `rdfs:label` and `rdfs:comment` of this type of auction.

## Ember models

There are a few things that I made note of with relation to Ember data models.

**Polymorphism** Due to inheritance, there are number of individuals that share the same parent class (in RDF). This is also modeled in the mu-cl-resources and therefore also in the Ember data models. RDF subclasses are now modeled by regular JavaScript inheritance with `extends`. This also leads to polymorphism in case of a one-to-many or many-to-many relation. For example, an auction has multiple lots, but these lots could be of any subclass of `Lot`. In order for Ember data to resolve this correctly, you need to add `@hasMany('lot', { polymorphic: true }) lots` in the `Auction` model.

**Transforms** These are not what I expected. I used them for a few things but they did not work out and I replaced most of them with plain getters, which also means that the components needed to be changed again. The problem is that transformations need to be completely lossless. This means that no information can get lost during translation in either direction. If information gets lost, you can not give back the original value of the property. Even if that property wasn't intentionally changed, the new property with information loss gets saved to the database when you save the object. For example: a bid contains a timestamp of exactly when the user made a bid on a lot. To present this timestamp to the user, only the hours and minutes are shown and you could use a transform to format the time in a nice way. However, formatting the time in a string like this means that you will lose the day, month, year, seconds, milliseconds, timezone, &hellip; information of that date because the new time string will replace the original date value. You could transform a string back into a date value, but you can not reconstruct the exact details. Instead I used regular getters to get a nicely formatted string and leave the original value untouched.

**Render-modifiers** I don't understand how anyone can make a beautifull webapp without [Ember Render Modifiers](https://github.com/emberjs/ember-render-modifiers). These are a crucial thing if you want some code to be executed for a component. For example: dynamically show the time left for an auction lot. You need a way to tell if the component is rendered to start an interval where a function updates the time displayed on screen. Render modifiers to the rescue! Another example: only show a favorite button if something is not already marked as favorite, and only if you really have to show that component. You need to execute a function that searches through a user's favorites to see if it has already been marked as favorite. That function sets a boolean that you can used in an `if` in the component. Render modifiers to the rescue again! More examples: using the Bootstrap framework sometimes requires you to execute JavaScript code, only after the component is rendered in the browser of course. Render modifiers to the &hellip; Why is this not built into Ember by default?!

## Users and mu-authorization

To manage users in the application, I divided them into multiple subclasses: participants and support. Participants consist of clients and sellers. Only clients can really bid on lots while only sellers can get in contact with the auction company to put items up for sale on the webapp. I created these subclasses before knowing how mu-authorization works. It turns out that this is actually a feasable way of separating user types, because the mu-authorization is very configurable. Calculating authorizations can be done by SPARQL queries which can check for a user being of a certain subclass and having some specific properties. In fact, you could define authorizations per feature level in the webapp in extreme fine granularity, which is great!

Every user get their own personal graph in the database to protect their information from other users and to separate it from publicly avaliable information. The graph has the URI structure: `http://mu.semte.ch/persondata/<uuid of user>`. This graph contains all triples with the user as subject. All other triples are stored in the public graph `http://mu.semte.ch/graphs/public`.

## Mu-migrations

The migrations service is inteded to adapt the structure of the database, for example when the ontology changes and the data needs to reflect that change. That specific functionality was not very useful in this small demo app yet, because when the model changes, you can just clean the database and reload the model and testdata. Instead, I used it for inserting test data and to transform this test data in a format that mu-authorization wants. The ontology and the individuals are described in Turtle syntax in separate `.ttl` files. The mu-migrations service picks these up in alphabetical order based on the filename and executes the necessary queries to import the data in the database. A third file contains a query that moves all properties of a user into their own graph, thus creating a graph per user. A fourth file contains a query that moves all remaining data to a public graph. Access to these graphs is enforced my mu-authorization.

## Problems with authorization

There were many problems with access control with mu-authorization after logging in. Mu-authorization was not the problem because it always calculated the user groups correctly when no cache was given. After logging in, the user groups cache in the HTTP headers from the identifier would always revert to the defaults as specified in environment variables in Docker's configuration. Normally, the login service sends a `CLEAR` in the header for the user groups, and other services would then forget about the cached user groups so that mu-authorization recalculates the user groups on the next request. It could also send updated values for the user groups that would need to be picked up by the identifier from then on. This mechanism is somehow broken in this demo app and after countless hours of trying to figure out why, I opted to implement a service just for this cache-clearing mechanism. A mock-access microservice responds to any post by replying with an empty document with the `mu-auth-allowed-groups` set to `CLEAR`. The defaults in Docker's configuration are set so only publicly available data can be seen. When the login in the webapp was successful, it also sends a post request to this microservice, before navigating to pages where personal data is requested.

## Other general remarks

During the making of this demo app, I made a few remarks, not knowing if someone has thought of these things before.

I have noticed that the webapp is sometimes rather slow, especially with the log messages of Docker open on the foreground. That means logging is not asynchronous? This would also mean that, if you want the absolute best performance for the app, you should disable logging, except for when it is really necessary, e.g. in case of serious errors.

I have also noticed that mu-cl-resources sends out a lot of smaller queries. A human would construct bigger queries to get all individuals and their properties at once, but the mu-cl-resources splits this up into a query to get the URI's for all the individuals and then a query per URI to get the relevant property values. Is this because the mu-authorization cannot handle larger queries trying to figure out access control? Or is it because of otherwise larger implementation complexity in the mu-cl-resources? I *assume* that sending a lot of smaller queries poses more overhead than sending a single large query that needs a little cleaning up. Every query goes through multiple steps being serialised and deserialised into an HTTP request and transformed into and from JSON, both in the mu-cl-resources and the SPARQL endpoint. The database also has to start multiple small queries instead of being able to work on a single larger batch of work. The biggest slowdown would certainly be the network traffic, which could easily be a few orders of magnitude slower than direct process communication, even in fully virtual networks like Docker's internal network. I think we could improve on the performance of mu-cl-resources by giving it the ability to reconstruct objects from a larger set of results from the database.  
Some considerations about changing the mu-cl-resources:

*	What with queries that grow out of usable proportions? Should we then switch to the old approach? (Optimistic approach = just try, and if failure, switch to different method; or pessimistic approach = try to prevent failure)
*	At what point is reconstructig objects on mu-cl-resources slower/faster than getting properties per subject from the database (if such point even exists).

The mu.semte.ch vocabularies do not exist in explicit form. I understand that you can use RDF properties without explicitely defining them. Most microservices only user one or two properties from a specific vocabulary and because of their proper name, you know what the property means. However, it would be nice to have them explicitely defined somewhere and properly documented (also with `rdfs:label` and `rdfs:comment` at least).

Virtuoso database has a few quirks. It does not allow for using blank nodes in certain queries, but allows it in similar, but slightly different queries. This is annoying when you used a tool like Protégé which creates blank nodes when defining constraints. Trying to use this exported data in mu-migrations results in the creation of the exact type of query Virtuoso does not support blank nodes in. Manually writing this out to use dummy nodes solves the issue, or using a newer version of Virtuoso (whenever it comes out in the future) could solve that problem too.  
Some `INSERT` queries fail because of some internal Virtuoso bug. It sometimes complains about a function called `string_output_string` that deals with logging and output to the terminal. The worse part is that the actual query is executed (data is deleted or inserted), but the response code is negative because of the failure of such helper function afterward. This can be solved by applying a bogus `BIND` in the `WHERE` clause, like so: `BIND(?s as ?s)`. This is stupid.

There are a couple of bugs that I encountered in different microservices.

*	Login-service: it can not deal with literals being typed with "^^...". For example, the username `"ben"^^xsd:string` causes failure to login.
*	Login-service: it removes everything that has a `session:account` pointing to the account being used to log in. Because I defined `session:account` to users (not knowing it could do any harm), the login service removed too much data. [(Check here)](https://github.com/mu-semtech/login-service/blob/e51cb1c795803aa14b9acb12caab751502deb063/login_service/sparql_queries.rb#L72)
*	Ember-mu-login plugin: `{{on "submit" this.logout}}` can not be used on a form, an otherwise logical place to use that. The problem is that the form submission makes the page reload, aborting any asynchronous calls to the login service trying to log off properly. An `event.preventDefault();` is needed in the event handler for submit, or this could be written in the plugin code itself (or at least documented somewhere that this could be a problem).
*	Caching user groups: wouldn't it be better to let the mu-authorization do the caching of user groups itself? Now, these groups are constantly transported between services and the identifier services needs to take special care to clean these headers at the correct time etc. There already is a unique session identifier in the headers of the identifier, which the mu-authorization can use to identify cached user groups. Clearing the caches can simply be achieved by creating a new session identifier that has no caches attached to it. Stale caches can be removed periodically in the mu-authorization.
*	mu-authorization: `INSPECT_OUTGOING_SPARQL_QUERY_RESPONSES` log does not do the expected. This logs the query instead of the responses.

