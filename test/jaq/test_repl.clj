(ns jaq.test-repl
  (:require
   [clojure.string :as string]
   [clojure.test :refer :all]
   [jaq.repl :as repl]))

(deftest test-input
  (let [input ":foo"
        {:keys [val]} (repl/repl {:input input})]
    (testing "input"
      (is (= val input)))))

(deftest test-exception-caught
  (repl/repl
   {:input "(throw (Exception. \"noop\"))"}))

(deftest test-session
  (let [session-id :session-id
        input ":bar"]
    (repl/session-repl {:input input :session-id session-id})
    (is
     (= input
        (:val (repl/session-repl {:session-id session-id :input "*1"}))))))

(deftest test-default-session
  (let [{:keys [session-id]} (repl/session-repl {:input ":foo"})]
    (is (not (nil? session-id)))))

(deftest test-bindings
  (let [{:keys [ns]} (repl/repl {:input "(def foo :foo)"})]
    (is (= (eval (read-string (str ns "/foo"))) :foo))))

(deftest test-reader-opts-default
  (let [{:keys [val]} (repl/repl {:input "#?(:clj :foo)"})]
    (is (= val ":foo"))))

(deftest test-reader-conditional
  (let [{:keys [val exception]} (repl/repl {:input "#?(:clj :foo)"
                                            :reader-opts {}})]
    (is
     (and (string/includes? val "RuntimeException")
          exception))))

(deftest test-ms
  (let [{:keys [ms]} (repl/repl {:input "(Thread/sleep 100)"})]
    (is (> ms 0))))

(defn -main [& args]
  (run-tests 'jaq.test-repl))
