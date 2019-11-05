(ns jaq.test-repl
  (:require
   [clojure.string :as string]
   [clojure.test :refer :all]
   [jaq.repl :as repl]))

(deftest test-input
  (let [input ":foo"
        {:keys [value]} (repl/repl {:input input})]
    (testing "input"
      (is (= value input)))))

(deftest test-exception-caught
  (repl/repl
   {:input "(throw (Exception. \"noop\"))"}))

(deftest test-session
  (let [session-id :session-id
        input ":bar"]
    (repl/session-repl {:input input :session-id session-id})
    (is
     (= input
        (:value (repl/session-repl {:session-id session-id :input "*1"}))))))

(deftest test-default-session
  (let [{:keys [session-id]} (repl/session-repl {:input ":foo"})]
    (is (not (nil? session-id)))))

(deftest test-bindings
  (let [{:keys [ns]} (repl/repl {:input "(def foo :foo)"})]
    (is (= (eval (read-string (str ns "/foo"))) :foo))))

(deftest test-reader-opts-default
  (let [{:keys [value]} (repl/repl {:input "#?(:clj :foo)"})]
    (is (= value ":foo"))))

(deftest test-reader-conditional
  (let [{:keys [value]} (repl/repl {:input "#?(:clj :foo)"
                                    :reader-opts {}})]
    (is (string/includes? value "RuntimeException"))))

(defn -main [& args]
  (run-tests 'jaq.test-repl))
