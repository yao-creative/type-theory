def add1 (n : Nat) : Nat := n + 1

#eval add1 7



def maximum (n: Nat) (k: Nat) : Nat :=
 if n < k then
  k
 else n


def spaceBetween (before : String) (after : String) : String :=
  String.append before (String.append " " after)

#eval maximum 2 4

#eval spaceBetween "Hello" "My Friend"


def joinStringsWith (first : String) (second: String) (third : String) : String :=
  String.append first (String.append second third)

#eval joinStringsWith "Lean " "is " "sexy"

