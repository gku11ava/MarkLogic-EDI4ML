(:
Copyright 2012-2015 MarkLogic Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)(:
xquery version "1.0-ml";

import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
import module namespace def = "http://marklogic.com/roxy/defaults" at "/roxy/config/defaults.xqy";
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

declare namespace rest = "http://marklogic.com/appservices/rest";

declare option xdmp:mapping "false";

let $uri  := xdmp:get-request-url()
let $method := xdmp:get-request-method()
let $path := xdmp:get-request-path()
let $final-uri :=
  req:rewrite(
    $uri,
    $path,
    $method,
    $config:ROXY-ROUTES)
return
  if ($final-uri) then $final-uri
  else
    try
    {
      xdmp:eval('
        import module namespace conf = "http://marklogic.com/rest-api/endpoints/config"
          at "/MarkLogic/rest-api/endpoints/config.xqy";
        declare variable $method external;
        declare variable $uri external;
        declare variable $path external;
        (conf:rewrite($method, $uri, $path), $uri)[1]',
        (xs:QName("method"), $method,
         xs:QName("uri"), $uri,
         xs:QName("path"), $path))
    }
    catch($ex) {
      if ($ex/error:code = "XDMP-MODNOTFOUND") then
        $uri
      else
        xdmp:rethrow()
    }
    :)
xquery version "1.0-ml";

import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
import module namespace def = "http://marklogic.com/roxy/defaults" at "/roxy/config/defaults.xqy";
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

declare namespace rest = "http://marklogic.com/appservices/rest";

declare option xdmp:mapping "false";

let $uri  := xdmp:get-request-url()
let $method := xdmp:get-request-method()
let $path := xdmp:get-request-path()
let $final-uri :=
  req:rewrite(
    $uri,
    $path,
    $method,
    $config:ROXY-ROUTES)
return
  if ($final-uri) then $final-uri
  else
    try
    {
      xdmp:eval('
      import module namespace conf = "http://marklogic.com/rest-api/endpoints/config"
                at "/MarkLogic/rest-api/endpoints/config.xqy";
      import module namespace rest = "http://marklogic.com/appservices/rest"
        at "/MarkLogic/appservices/utils/rest.xqy";
      import module namespace eput = "http://marklogic.com/rest-api/lib/endpoint-util"
          at "/MarkLogic/rest-api/lib/endpoint-util.xqy";
              declare variable $method external;
              declare variable $uri external;
              declare variable $path external;

      (: This is a hack, but allows us to maintain one rule set endpoints and rewriter,
          while pushing the finer-grained error handling to the endpoint level. :)
      declare function conf:rewrite-rules(
      ) as map:map
      {
          let $old-rules := eput:get-rest-options()
          return
              if (exists($old-rules))
              then $old-rules
              else
                  let $all-methods := ("GET","POST","PUT","DELETE","HEAD","OPTIONS")
                  let $new-rules   := map:map()
                  let $unsupported := map:map()
                  return (
                      for $rule in (
                          conf:get-default-request-rule(),
                          conf:get-config-indexes-request-rule(),
                          conf:get-config-namespaces-item-request-rule(),
                          conf:get-config-namespaces-request-rule(),
                          conf:get-config-properties-request-rule(),
                          conf:get-config-query-child-request-rule(),
                          conf:get-config-query-list-request-rule(),
                          conf:get-config-query-request-rule(),
                          conf:get-document-query-rule(),
                          conf:get-document-update-rule(),
                          conf:get-keyvalue-list-request-rule(),
                          conf:get-qbe-request-rule(),
                          conf:get-ping-request-rule(),
                          conf:get-rsrc-list-query-rule(),
                          conf:get-rsrc-item-query-rule(),
                          conf:get-rsrc-item-update-rule(),
                          conf:get-rsrc-exec-query-rule(),
                          conf:get-rsrc-exec-update-rule(),
                          conf:get-search-query-request-rule(),
                          conf:get-search-update-request-rule(),
                          conf:get-tfm-list-request-rule(),
                          conf:get-tfm-item-request-rule(),
                          conf:get-txn-request-rule(),
                          conf:get-values-request-rule(),
                          conf:get-sparql-protocol-rule(),
                          conf:get-graph-explore-rule(),
                          conf:get-graphstore-protocol-rule(),
                          conf:get-suggest-request-rule(),
                          conf:get-rules-list-rule(),
                          conf:get-alert-rules-item-rule(),
                          conf:get-alert-match-rule(),
                          conf:get-extlib-root-request-rule(),
                          conf:get-extlib-request-rule()
                          )
                      let $endpoint   := $rule/@endpoint/string(.)
                      (: Note: depends on document order in rule :)
                      let $uri-params := $rule/rest:uri-param/@name/string(.)
                      let $methods    := $rule/rest:http/@method/tokenize(string(.)," ")
                      for $match in $rule/@fast-match/tokenize(string(.), "\|")
                      return (
                          for $method in $methods
                          return map:put($new-rules, $method||$match, ($endpoint,$uri-params)),

                          let $candidates :=
                              let $candidate-methods := map:get($unsupported,$match)
                              return
                                  if (exists($candidate-methods))
                                  then $candidate-methods
                                  else $all-methods
                          return map:put(
                              $unsupported, $match, $candidates[not(. = $methods)]
                              )
                          ),

                      for $match in map:keys($unsupported)
                      for $method in map:get($unsupported,$match)
                      return map:put(
                          $new-rules,
                          $method||$match,
                          "/MarkLogic/rest-api/endpoints/unsupported-method.xqy"
                          ),

                      eput:set-rest-options($new-rules),
                      $new-rules
                      )
      };

      declare function conf:rewrite(
          $method   as xs:string,
          $uri      as xs:string,
          $old-path as xs:string
      ) as xs:string?
      {
          let $rules      := conf:rewrite-rules()
          (: skip the empty step before the initial / :)
          let $raw-steps  := subsequence(tokenize($old-path,"/"), 2)
          let $raw-count  := count($raw-steps)
          (: check for an empty step after a trailing / :)
          let $extra-step := (subsequence($raw-steps,$raw-count,1) eq "")
          let $step-count :=
              if ($extra-step)
              then $raw-count - 1
              else $raw-count
          let $steps      :=
              if ($step-count eq 0)
              then ()
              else if ($extra-step)
              then subsequence($raw-steps, 1, $step-count)
              else $raw-steps
          (: generate the key for lookup in the rules map :)
          let $key        :=
              (: no rule :)
              if ($step-count eq 1)
              then ()
              (: default rule :)
              else if ($step-count eq 0)
              then ""
              else
                  let $first-step := subsequence($steps,1,1)
                  return
                  (: as in /content/help :)
                  if ($first-step eq "content")
                  then ($first-step,"*")
                  else if (not($first-step = ("v1","LATEST")))
                  (: no rule :)
                  then ()
                  else
                      let $second-step := subsequence($steps,2,1)
                      return
                      (: as in /v1/documents :)
                      if ($step-count eq 2)
                      then ("*",$second-step)
                      else
                          let $third-step := subsequence($steps,3,1)
                          return
                          if ($second-step = ("ext"))
                          then
                          ("*",$second-step,"**")
                          else if ($second-step = ("config","alert","graphs")) then
                              (: as in /v1/config/namespaces :)
                              if ($step-count eq 3)
                              then ("*", $second-step, $third-step)
                              (: /v1/config/options/NAME or /v1/config/options/NAME/SUBNAME :)
                              else if ($step-count le 5)
                              then ("*", $second-step, $third-step, (4 to $step-count) ! "*")
                              else ()
                          (: as in /v1/transactions/TXID :)
                          else if ($step-count eq 3)
                          then ("*", $second-step, "*")
                          (: catch all :)
                          else if ($step-count le 5)
                          then ("*", $second-step, $third-step, (4 to $step-count) ! "*")
                          (: no rule :)
                          else ()
          let $key-method :=
              if ($method eq "POST" and starts-with(
                  head(xdmp:get-request-header("content-type")), "application/x-www-form-urlencoded"
                  ))
              then "GET"
              else $method
          let $value :=
              if (empty($key)) then ()
              else map:get($rules, string-join(($key-method,$key), "/"))
          let $value-count := count($value)
          return
              (: fallback :)
              if ($value-count eq 0)
              then $uri
              else
                  let $old-length := string-length($old-path)
                  let $has-params := (string-length($uri) ne $old-length)
                  let $new-path   :=
                      (: append parameters to the rewritten path :)
                      if ($has-params)
                      then subsequence($value,1,1)||substring($uri,$old-length+1)
                      else subsequence($value,1,1)
                  return
                      if ($value-count eq 1)
                      then $new-path
                      (: append parameters from rule to the rewritten path :)
                      else string-join(
                          (
                              $new-path,
                              let $step-names := subsequence($value,2)
                              for $step-value at $i in
                                  for $j in 2 to count($key)
                                  let $place-holder := subsequence($key,$j,1)
                                  return
                                      if ($place-holder eq "*")
                                      then subsequence($steps,$j,1)
                                      else if ($place-holder eq "**")
                                      (: using raw-steps picks up trailing slash :)
                                      then string-join(subsequence($raw-steps,$j),"/")
                                      else ()

                              return (
                                  if ($has-params or $i gt 1)
                                      then "&amp;amp;"
                                      else "?",
                                  subsequence($step-names,$i,1),
                                  "=",
                                  $step-value
                                  )
                              ),
                          ""
                          )
      };

          (conf:rewrite($method, $uri, $path), $uri)[1]',
          (xs:QName("method"), $method,
           xs:QName("uri"), $uri,
           xs:QName("path"), $path))
    }
    catch($ex) {
      if ($ex/error:code = "XDMP-MODNOTFOUND") then
        $uri
      else
        xdmp:rethrow()
    }