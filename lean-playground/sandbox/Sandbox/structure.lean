-- Σ from type theory


#check 1.2

#check -454.212


structure Point where
  x : Float
  y : Float


-- Definitinoal equation Ctx = ∅, t = Point, u = {0.0, 0.0}, A (type) = Float x Float
def origin : Point := {x := 0.0, y := 0.0}

#eval origin.x


