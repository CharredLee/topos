import Mathlib.CategoryTheory.Limits.Shapes.Pullbacks
import Mathlib.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathlib.CategoryTheory.Closed.Cartesian
import Topos.Basic
import Topos.Category


namespace CategoryTheory

open Category Limits Classifier Power Topos

universe u v

variable {C : Type u} [Category.{v} C] [Topos C]

/-!
# Exponential Objects

Proves that a topos has exponential objects (internal homs).
Consequently, every topos is Cartesian closed.
-/


namespace CategoryTheory
namespace Topos

noncomputable section

/-- The exponential object B^A. -/
def Exp (A B : C) : C :=
  pullback
    (P_transpose (P_transpose ((prod.associator _ _ _).inv ≫ in_ (B ⨯ A)) ≫ Predicate.isSingleton B))
    (Name (Predicate.true_ A))

/-- The map which, in Set, sends a function (A → B) ∈ B^A to its graph as a subset of B ⨯ A. -/
def Exp_toGraph (A B : C) : Exp A B ⟶ Pow (B ⨯ A) := pullback.fst

@[simp]
lemma ExpConeSnd_Terminal (A B : C) : pullback.snd = terminal.from (Exp A B) := Unique.eq_default _

def Exp_comm (A B : C) : Exp_toGraph A B ≫ (P_transpose (P_transpose ((prod.associator _ _ _).inv ≫ in_ (B ⨯ A)) ≫ Predicate.isSingleton B))
  = terminal.from (Exp A B) ≫ Name (Predicate.true_ A) := by
    rw [←ExpConeSnd_Terminal]; exact pullback.condition

/-- The evaluation map eval : A ⨯ B^A ⟶ B. -/
def eval (A B : C) : A ⨯ (Exp A B) ⟶ B := by
  let id_uniq : A ⨯ Exp A B ⟶ A ⨯ ⊤_ C := prod.map (𝟙 _) (terminal.from _)
  let id_m : A ⨯ Exp A B ⟶ A ⨯ Pow (B ⨯ A) := prod.map (𝟙 _) (Exp_toGraph A B)
  let id_nameOfTrue : A ⨯ ⊤_ C ⟶ A ⨯ Pow A := prod.map (𝟙 _) (Name (Predicate.true_ A))
  -- #check in_ (A ⨯ B)
  let σ_B : Pow B ⟶ Ω C := Predicate.isSingleton B
  let v : A ⨯ Pow (B ⨯ A) ⟶ Pow B := P_transpose ((prod.associator _ _ _).inv ≫ in_ (B ⨯ A))
  let u : Pow (B ⨯ A) ⟶ Pow A := P_transpose (v ≫ Predicate.isSingleton B)
  let id_u : A ⨯ Pow (B ⨯ A) ⟶ A ⨯ Pow A := prod.map (𝟙 _) u
  have comm_middle : v ≫ σ_B = id_u ≫ (in_ A) := Pow_powerizes A (v ≫ σ_B)
  have comm_left : id_m ≫ id_u =  id_uniq ≫ id_nameOfTrue := by
    rw [prod.map_map, prod.map_map]
    ext; simp
    rw [prod.map_snd, prod.map_snd, Exp_comm]
  -- checking commutativity of the big rectangle.
  have h_terminal : (prod.map (𝟙 A) (terminal.from (Exp A B)) ≫ prod.fst) ≫ terminal.from A = terminal.from _ :=
      Unique.eq_default _
  have comm : (id_m ≫ v) ≫ σ_B = Predicate.true_ (A ⨯ Exp A B) := by
    rw [assoc, comm_middle, ←assoc, comm_left, assoc, Predicate.true_, ←Predicate.NameDef]
    dsimp [Predicate.true_]
    rw [←assoc, ←assoc, h_terminal]
  exact ClassifierCone_into (singleton B) (id_m ≫ v) comm



abbrev Exponentiates {A B X HomAB : C}  (e : A ⨯ HomAB ⟶ B) (f : A ⨯ X ⟶ B) (f_exp : X ⟶ HomAB) :=
  f = (prod.map (𝟙 _) f_exp) ≫ e

structure IsExponentialObject {A B HomAB : C} (e : A ⨯ HomAB ⟶ B) where
  exp : ∀ {X} (_ : A ⨯ X ⟶ B), X ⟶ HomAB
  exponentiates : ∀ {X} (f : A ⨯ X ⟶ B), Exponentiates e f (exp f)
  unique' : ∀ {X} {f : A ⨯ X ⟶ B} {exp' : X ⟶ HomAB}, Exponentiates e f exp' → exp f = exp'

class HasExponentialObject (A B : C) where
  HomAB : C
  e : A ⨯ HomAB ⟶ B
  is_exp : IsExponentialObject e

variable (C)

class HasExponentialObjects where
  has_exponential_object : ∀ (A B : C), HasExponentialObject A B

variable {C}

attribute [instance] HasExponentialObjects.has_exponential_object

-- ## TODO
-- exhibit the type class instance `HasExponentialObjects C` for a topos `C`.

def Exp_map {A B X : C} (f : A ⨯ X ⟶ B) : X ⟶ Exp A B := by
  let id_f'diag : B ⨯ A ⨯ X ⟶ Ω C := (prod.map (𝟙 _) f) ≫ (Predicate.eq _)
  let h : X ⟶ Pow (B ⨯ A) := P_transpose ((prod.associator _ _ _).hom ≫ id_f'diag)
  apply pullback.lift h (terminal.from X)
  have h_def : (prod.associator _ _ _).hom ≫ id_f'diag = (prod.map (prod.map (𝟙 _) (𝟙 _)) h) ≫ in_ _ := by
    rw [prod.map_id_id]
    apply Pow_powerizes
  have singleton_def : Predicate.eq B = (prod.map (𝟙 _) (singleton B)) ≫ in_ B := by apply Pow_powerizes
  let v : A ⨯ Pow (B ⨯ A) ⟶ Pow B := P_transpose ((prod.associator _ _ _).inv ≫ in_ (B ⨯ A))
  let v_def : v = P_transpose ((prod.associator _ _ _).inv ≫ in_ (B ⨯ A)) := rfl
  rw [←v_def]
  -- ### TODO
  -- fill in this proof. Shouldn't be too bad, just a lot of book-keeping.

  sorry

theorem Exp_Exponentiates {A B X : C} (f : A ⨯ X ⟶ B) : Exponentiates (eval A B) f (Exp_map f) := by
  dsimp [Exponentiates, eval] -- yikes!

  sorry


instance Exp_isExponential (A B : C) : IsExponentialObject (eval A B) where
  exp := fun f ↦ Exp_map f
  exponentiates := Exp_Exponentiates
  unique' := fun {X} (f : A ⨯ X ⟶ B) {exp' : X ⟶ Exp A B} ↦ by {
    intro h
    dsimp [Exponentiates]
    rw [Exponentiates] at h
    #check (cancel_mono (singleton B)).mpr
    have h_singleton := (cancel_mono (singleton _)).mpr h
    -- rw [pullback.lift_fst] at h_singleton

    sorry
  }

variable (X Y : C)

#check (prod.braiding X (Exp X Y)).hom


def InternalComposition {X Y Z : C} : (Exp X Y) ⨯ (Exp Y Z) ⟶ Exp X Z :=
  Exp_map ((prod.associator X (Exp X Y) (Exp Y Z)).inv ≫ (prod.map (eval X Y) (𝟙 _)) ≫ eval Y Z)

-- ## TODO
-- exhibit `CartesianClosed C` for a topos `C`.

def ExpHom {X Y : C} (A : C) (f : X ⟶ Y) : Exp A Y ⟶ Exp A X := sorry

def ExpFunctor (A : C) : Cᵒᵖ ⥤ C where
  obj := fun ⟨B⟩ ↦ Exp A B
  map := fun {X Y} ⟨f⟩ ↦ ExpHom A f
  map_id := sorry
  map_comp := sorry


instance CartesianClosed : CartesianClosed C := by
  apply CartesianClosed.mk
  intro B

  sorry


end
end Topos
end CategoryTheory
