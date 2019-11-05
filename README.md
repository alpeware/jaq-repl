# JAQ repl

A repl suitable for stateless protocols such as HTTP.

## Rationale

Most repls require a persistent stream in the form of standard i/o or TCP
per client. This is not suitable for most Cloud based deployments.

## Installation

Use in ```deps.edn``` -

```
{com.alpeware/jaq-services {:git/url "https://github.com/alpeware/jaq-repl"
                            :sha "LATEST SHA"}}
```

## Status

Public API stable.

## Usage

The following API is provided in `jaq.repl`:
* `(repl opts) ;; repl w/o session management`
* `(session-repl opts) ;; repl w/ session management`

## Example Usage

```clojure
(require '[jaq.repl :as repl])

;; just eval w/ default reader options and current thread bindings.
(repl/repl {:input ":foo"})
;; => {:input ":foo", :value ":foo", :ns user, :bindings {#'clojure.core/*default-data-reader-fn* nil, #'clojure.core/*unchecked-math* false, #<Var: --unnamed--> 1, #'clojure.core/*read-eval* true, #'clojure.core/*math-context* nil, #'clojure.core/*2 nil, #'clojure.core/*print-namespace-maps* true, #'clojure.core/*1 :foo, #<Var: --unnamed--> #object[clojure.lang.DynamicClassLoader 0x1ab6718 "clojure.lang.DynamicClassLoader@1ab6718"], #'clojure.core/*compile-path* "classes", #'clojure.core/*assert* true, #'clojure.core/*warn-on-reflection* false, #'clojure.core/*3 nil, #'clojure.core/*print-length* nil, #<Var: --unnamed--> 1, #'clojure.core/*command-line-args* nil, #'clojure.core/*print-level* nil, #'clojure.core/*ns* #object[clojure.lang.Namespace 0x74075134 "user"], #'clojure.core/*data-readers* {}, #'clojure.core/*print-meta* false, #'clojure.spec.alpha/*explain-out* #object[clojure.spec.alpha$explain_printer 0x7e4d2287 "clojure.spec.alpha$explain_printer@7e4d2287"], #'clojure.core/*e nil}}

;; eval w/ session
(repl/session-repl {:input ":bar"})
;; => {:input ":bar", :session-id #uuid "36d6f272-44b1-4343-91c6-8d945c63d244", :value ":bar", :ns user, :bindings {#'clojure.core/*default-data-reader-fn* nil, #'clojure.core/*unchecked-math* false, #<Var: --unnamed--> 1, #'clojure.core/*read-eval* true, #'clojure.core/*math-context* nil, #'clojure.core/*2 {:input ":foo", :value ":foo", :ns user, :bindings {#'clojure.core/*default-data-reader-fn* nil, #'clojure.core/*unchecked-math* false, #<Var: --unnamed--> 1, #'clojure.core/*read-eval* true, #'clojure.core/*math-context* nil, #'clojure.core/*2 nil, #'clojure.core/*print-namespace-maps* true, #'clojure.core/*1 :foo, #<Var: --unnamed--> #object[clojure.lang.DynamicClassLoader 0x1ab6718 "clojure.lang.DynamicClassLoader@1ab6718"], #'clojure.core/*compile-path* "classes", #'clojure.core/*assert* true, #'clojure.core/*warn-on-reflection* false, #'clojure.core/*3 nil, #'clojure.core/*print-length* nil, #<Var: --unnamed--> 1, #'clojure.core/*command-line-args* nil, #'clojure.core/*print-level* nil, #'clojure.core/*ns* #object[clojure.lang.Namespace 0x74075134 "user"], #'clojure.core/*data-readers* {}, #'clojure.core/*print-meta* false, #'clojure.spec.alpha/*explain-out* #object[clojure.spec.alpha$explain_printer 0x7e4d2287 "clojure.spec.alpha$explain_printer@7e4d2287"], #'clojure.core/*e nil}}, #'clojure.core/*print-namespace-maps* true, #'clojure.core/*1 :bar, #<Var: --unnamed--> #object[clojure.lang.DynamicClassLoader 0x3f4b840d "clojure.lang.DynamicClassLoader@3f4b840d"], #'clojure.core/*compile-path* "classes", #'clojure.core/*assert* true, #'clojure.core/*warn-on-reflection* false, #'clojure.core/*3 nil, #'clojure.core/*print-length* nil, #<Var: --unnamed--> 1, #'clojure.core/*command-line-args* nil, #'clojure.core/*print-level* nil, #'clojure.core/*ns* #object[clojure.lang.Namespace 0x74075134 "user"], #'clojure.core/*data-readers* {}, #'clojure.core/*print-meta* false, #'clojure.spec.alpha/*explain-out* #object[clojure.spec.alpha$explain_printer 0x7e4d2287 "clojure.spec.alpha$explain_printer@7e4d2287"], #'clojure.core/*e nil}}

;; eval w/ session id
(-> {:session-id :some-session :input ":baz"}
  (repl/session-repl)
  (conj {:input "*1"})
  (repl/session-repl)
  :value)
;; => ":baz"
```

## License

Copyright © 2019 Alpeware, LLC.

Distributed under the Eclipse Public License, the same as Clojure.
