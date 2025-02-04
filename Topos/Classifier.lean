/-
Copyright (c) 2024 Charlie Conneen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charlie Conneen
-/

import Mathlib.CategoryTheory.Limits.Shapes.Pullback.CommSq
import Mathlib.CategoryTheory.Limits.Shapes.RegularMono
import Mathlib.Tactic.ApplyFun

/-!

# Subobject Classifier

We define what it means for a morphism in a category to be a subobject
classifier as `CategoryTheory.Classifier.IsClassifier`.

## Main definitions

Let `C` refer to a category with a terminal object.

* `CategoryTheory.MonoClassifier.IsClassifier` describes what it means for a
  pair of an object `Ω : C` and a morphism `t : ⊤_ C ⟶ Ω` to be a subobject
  classifier for `C`.

* `CategoryTheory.MonoClassifier.Classifier C` is the data of `C` having a
  subobject classifier.

## Main results

* It is a theorem that the truth morphism `⊤_ C ⟶ Ω C` is a (split, and
  therefore regular) monomorphism.

* `MonoClassifier.balanced` shows that any category with a subobject classifier
  is balanced. This follows from the fact that every monomorphism is the
  pullback of a regular monomorphism (the truth morphism).

## Notation

* if `m` is a monomorphism, `χ_ m` denotes characteristic map of `m`,
  which is the corresponding map to the subobject classifier.

## References

* [S. MacLane and I. Moerdijk, *Sheaves in Geometry and Logic*][MLM92]

-/


universe u v u₀ v₀

open CategoryTheory Category Limits Functor

variable (C : Type u) [Category.{v} C] [HasTerminal C]

namespace CategoryTheory.MonoClassifier

/-- A morphism `t : ⊤_ C ⟶ Ω` from the terminal object of a category `C`
is a subobject classifier if, for every monomorphism `m : U ⟶ X` in `C`,
there is a unique map `χ : X ⟶ Ω` such that the following square is a pullback square:
```
      U ---------m----------> X
      |                       |
terminal.from U               χ
      |                       |
      v                       v
    ⊤_ C --------t----------> Ω
```
-/
structure Classifier where
  /-- The target of the truth morphism -/
  {Ω : C}
  /-- the truth morphism for a subobject classifier -/
  t : ⊤_ C ⟶ Ω
  /-- For any monomorphism `U ⟶ X`, there is an associated characteristic map `X ⟶ Ω`. -/
  char {U X : C} (m : U ⟶ X) [Mono m] : X ⟶ Ω
  /-- `char m` forms the appropriate pullback square. -/
  isPullback {U X : C} (m : U ⟶ X) [Mono m] : IsPullback m (terminal.from U) (char m) t
  /-- `char m` is the only map `X ⟶ Ω` which forms the appropriate pullback square. -/
  uniq {U X : C} (m : U ⟶ X) [Mono m] (χ : X ⟶ Ω) (hχ : IsPullback m (terminal.from U) χ t) :
    χ = char m

/-- A category `C` has a subobject classifier if there is at least one subobject classifier. -/
class HasClassifier : Prop where
  /-- There is some classifier. -/
  exists_classifier : Nonempty (Classifier C)

variable [HasClassifier C]

noncomputable section

/-- Notation for the object in an arbitrary choice of a subobject classifier -/
abbrev Ω : C := HasClassifier.exists_classifier.some.Ω

/-- Notation for the "truth arrow" in an arbitrary choice of a subobject classifier -/
abbrev t : ⊤_ C ⟶ Ω C := HasClassifier.exists_classifier.some.t

variable {C}
variable {U X : C} (m : U ⟶ X) [Mono m]

/-- returns the characteristic morphism of the subobject `(m : U ⟶ X) [Mono m]` -/
def characteristicMap : X ⟶ Ω C :=
  HasClassifier.exists_classifier.some.char m

/-- shorthand for the characteristic morphism -/
abbrev χ_ := characteristicMap m

/-- The diagram
```
      U ---------m----------> X
      |                       |
terminal.from U              χ_ m
      |                       |
      v                       v
    ⊤_ C -------t C---------> Ω
```
is a pullback square.
-/
lemma isPullback : IsPullback m (terminal.from U) (χ_ m) (t C) :=
  HasClassifier.exists_classifier.some.isPullback m

/-- The diagram
```
      U ---------m----------> X
      |                       |
terminal.from U              χ_ m
      |                       |
      v                       v
    ⊤_ C -------t C---------> Ω
```
commutes.
-/
@[reassoc]
lemma comm : m ≫ (χ_ m) = terminal.from _ ≫ t C := (isPullback m).w


/-- `characteristicMap m` is the only map for which the associated square
is a pullback square.
-/
lemma unique (χ : X ⟶ Ω C) (hχ : IsPullback m (terminal.from _) χ (t C)) : χ = χ_ m :=
  HasClassifier.exists_classifier.some.uniq m χ hχ


/-- `t C` is a regular monomorphism (because it is split). -/
noncomputable instance truthIsRegularMono : RegularMono (t C) :=
  RegularMono.ofIsSplitMono (t C)

/-- The following diagram
```
      U ---------m----------> X
      |                       |
terminal.from U              χ_ m
      |                       |
      v                       v
    ⊤_ C -------t C---------> Ω
```
being a pullback for any monic `m` means that every monomorphism
in `C` is the pullback of a regular monomorphism; since regularity
is stable under base change, every monomorphism is regular.
-/
noncomputable instance monoIsRegularMono {A B : C} (m : A ⟶ B) [Mono m] : RegularMono m :=
  regularOfIsPullbackFstOfRegular (isPullback m).w (isPullback m).isLimit

/-- `C` is a balanced category.  -/
instance balanced : Balanced C where
  isIso_of_mono_of_epi := fun f => isIso_of_epi_of_strongMono f

instance : Balanced Cᵒᵖ := balanced_opposite

/-- If the source of a faithful functor has a subobject classifier, the functor reflects
  isomorphisms. This holds for any balanced category.
-/
instance reflectsIsomorphisms (D : Type u₀) [Category.{v₀} D] (F : C ⥤ D) [Functor.Faithful F] :
    Functor.ReflectsIsomorphisms F :=
  reflectsIsomorphisms_of_reflectsMonomorphisms_of_reflectsEpimorphisms F

/-- If the source of a faithful functor is the opposite category of one with a subobject classifier,
  the same holds -- the functor reflects isomorphisms.
-/
instance reflectsIsomorphismsOp (D : Type u₀) [Category.{v₀} D]
(F : Cᵒᵖ ⥤ D) [Functor.Faithful F] :
    Functor.ReflectsIsomorphisms F :=
  reflectsIsomorphisms_of_reflectsMonomorphisms_of_reflectsEpimorphisms F

end
end CategoryTheory.MonoClassifier
