(ns jaq.repl.impl
  (:require
   [clojure.main :as main])
  (:import
   [java.util UUID]))

(def sessions (atom {}))

(def default-reader-opts
  "Reader options"
  {:read-cond :allow})

(defn- repl-caught
  "Default :caught hook for repl"
  [e]
  (let [ex (main/repl-exception e)
        tr (.getStackTrace ex)
        el (when-not (zero? (count tr)) (aget tr 0))]
    (str (-> ex class .getSimpleName)
         " " (.getMessage ex) " "
         (when-not (instance? clojure.lang.Compiler$CompilerException ex)
           (str " " (if el (main/stack-element-str el) "[trace missing]"))))))

(defn random-session []
  (UUID/randomUUID))

(defn repl
  "Evals input."
  [{:keys [reader-opts bindings input]
    :or {reader-opts default-reader-opts
         bindings (get-thread-bindings)}
    :as m}]
  (->>
   (main/with-bindings
     (with-bindings bindings
       (try
         (let [form (read-string reader-opts input)
               value (eval form)]
           (set! *3 *2)
           (set! *2 *1)
           (set! *1 value)
           {:value (pr-str value) :ns (symbol (str *ns*))
            :bindings (get-thread-bindings)})
         (catch Throwable e
           (set! *e e)
           {:value (repl-caught e) :ns (symbol (str *ns*))
            :bindings (get-thread-bindings)}))))
   (merge m)))

(defn session-repl
  "Uses a local atom to handle sessions."
  [{:keys [input session-id reader-opts bindings]
    :or {session-id (random-session)}
    :as m}]
  (->>
   (get @sessions session-id)
   ((fn [m]
      (-> m
          (select-keys [:bindings])
          (assoc :session-id session-id))))
   (merge m)
   (repl)
   (swap! sessions assoc session-id)
   ((fn [e]
      (get e session-id)))))

#_(
   *ns*
   (in-ns 'jaq.repl.impl)
)
