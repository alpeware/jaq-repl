(ns jaq.repl
  "An API for repls over stateless protocols such as HTTP."
  (:require
   [jaq.repl.impl :as impl]))

(defn repl
  "Evals input w/ bindings and reader options in the current thread.

  Returns a map w/ the value, ns and new bindings."
  [{:keys [reader-opts bindings input]
    :as m}]
  (impl/repl m))

(defn session-repl
  "Convenience repl w/ session handling."
  [{:keys [input session-id reader-opts bindings]
    :as m}]
  (impl/session-repl m))
