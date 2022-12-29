(import test ())

(defun double (x) (* x 2))
(defun add (a b) (+ a b))

(describe "A function"
  [may "be composed"
    (will "be a function"
          (affirm (= "function" (type (compose + *)))
                  (= "nil" (type (compose + nil)))
                  (= "nil" (type (compose nil +)))))
    (will "work"
          (affirm (= 5 ((compose succ double) 2))
                  (= 6 ((compose double succ) 2))))]
  [may "be cut"
    (will "be a function"
          [affirm (= "function" (type (cut + <> 2)))])
    (will "work"
          (affirm (= 3 ((cut + <> 2) 1))
                  (= 3 ((cut + 2 <>) 1))
                  (= "foo bar" ((cut .. <> " " <>) "foo" "bar"))))
    (will "have a fixed number of arguments"
          (affirm (= 1 (n ((cut list <>))))
                  (= 1 (n ((cut list <>) 1 2 3)))))
    (will "evalute args each time"
      (let* [(count 0)
             (get! (lambda () (inc! count) count))
             (+' (lambda (a b) (+ (a) b)))
             (fn (cut + (get!) <>))]
        (affirm (= 2 (fn 1))
                (= 3 (fn 1))
                (= 4 (fn 1)))))]
  [may "be cute"
    (will "be a function"
          (affirm (= "function" (type (cute + <> 2)))))
    (will "work"
          (affirm (= 3 ((cute + <> 2) 1))
                  (= 3 ((cute + 2 <>) 1))
                  (= "foo bar" ((cut .. <> " " <>) "foo" "bar"))))
    (will "have a fixed number of arguments"
          (affirm (= 1 (n ((cute list <>))))
                  (= 1 (n ((cute list <>) 1 2 3)))))
    (will-not "evalute args each time"
      (let* [(count 0)
             (get! (lambda () (inc! count) count))
             (fn (cute + (get!) <>))]
        (affirm (= 2 (fn 1))
                (= 2 (fn 1))
                (= 2 (fn 1)))))]
  [may "be curried"
    (will "be a function"
      (affirm (= "function" (type (curry add 1)))))
    (will "work"
      (affirm (= 2 ((curry add 1) 1))
              (= 3 ((curry add 2) 1))))]
  [may "be autocurried"
    (will "be a new function"
      (let [(sum (autocurry add 2))]
        (affirm (= "function" (type sum)))
        (will "still be a function on first arg supplied"
          (affirm (= "function" (type (sum 1)))))
        (will "apply args on final arity"
          (affirm (= 3 ((sum 1) 2))))))]
  [may "be chained"
    (will "work with functions"
          (affirm (= 5 (-> 2 (lambda (x) (* 2 x)) succ))
                  (= 7 (-> 2 succ (lambda (x) (* 2 x)) succ))))
    (will "work with slots"
          (affirm (= 5 (-> 2 (* <> 2) (+ 1 <>)))
                  (= 7 (-> 2 succ (* <> 2) (+ 1 <>)))))
    (it "evaluate in correct order"
       (let* [(count 1)
             (get! (lambda () (inc! count) count))]
         (affirm (=  1 (-> (get!) (- (get!) <>)))
                 (= -1 (-> (get!) (- <> (get!)))))))
    (it "evaluate args once"
      (let* [(count 0)
             (get! (lambda (_) (inc! count) count))]
        (affirm
          (= 2 (-> nil get! (+ <> <>)))
          (= 4 (-> (get!) (+ <> <>))))))]
  (will "be invokable"
        (affirm (invokable? +))))
