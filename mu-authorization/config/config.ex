alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do
  def user_groups do
    # These elements are walked from top to bottom.  Each of them may
    # alter the quads to which the current query applies.  Quads are
    # represented in three sections: current_source_quads,
    # removed_source_quads, new_quads.  The quads may be calculated in
    # many ways.  The useage of a GroupSpec and GraphCleanup are
    # common.
    [
      # // PUBLIC
      %GroupSpec{
        name: "public",
        useage: [:write, :read],
        access: %AlwaysAccessible{},
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/public",
                    constraint: %ResourceFormatConstraint{
                      #resource_prefix: "http://mu.semte.ch/application"
                      resource_prefix: ""
                    } } ] },
      # // Users acces their own graph
      %GroupSpec{
        name: "persondata",
        useage: [:read, :write],
        access: %AccessByQuery{
          vars: [ "uuid" ],
          query: "PREFIX mu:      <http://mu.semte.ch/vocabularies/core/>
                  PREFIX au:      <http://www.semanticweb.org/ben/ontologies/auction#>
                  PREFIX aud:     <http://www.semanticweb.org/ben/data/auction#>
                  PREFIX session: <http://mu.semte.ch/vocabularies/session/>
                  PREFIX account: <http://mu.semte.ch/vocabularies/account/>
                  PREFIX muMigr:  <http://mu.semte.ch/vocabularies/migrations/>
                  PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
                  SELECT ?uuid {
                    GRAPH <http://mu.semte.ch/graphs/public> {
                      <SESSION_ID> session:account ?account .
                      ?user foaf:account ?account .
                      ?user mu:uuid ?uuid .
                    }
                  }"

        },
#                  WHERE {
#                      ?user mu:uuid ?uuid .
#                      ?user foaf:firstName 'Ben' .
#                  } LIMIT 1
        graphs: [ %GraphSpec{
            graph: "http://mu.semte.ch/persondata/",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://www.semanticweb.org/ben/ontologies/auction#Client",
                "http://www.semanticweb.org/ben/ontologies/auction#Seller",
                "http://www.semanticweb.org/ben/ontologies/auction#Administrator",
              ],
              predicates: %AllPredicates{
                except: [
                  "http://mu.semte.ch/vocabularies/core/uuid",      #mu:uuid
                  "http://xmlns.com/foaf/0.1/account",              #foaf:account
                  "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" #a / rdf:type
                ]
              }
            }
          }
        ]
      },

      # // CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end

