Open Scope list_scope.

Inductive code_element (A : Set) : Set :=
|fst : (code_element A)
|snd : (code_element A)
|quote : A -> (code_element A)
|cur : (list (code_element A)) -> (code_element A)
|push : (code_element A)
|swap : (code_element A)
|cons : (code_element A)
|app : (code_element A).

Definition code (A : Set) := (list (code_element A)).

Inductive stack_element (A : Set) : Set :=
|constante: A -> (stack_element A)
|paire: (stack_element A) -> (stack_element A) -> (stack_element A) (* (s, t) : (paire s t)*)
|avec_code: (code A) -> (stack_element A) -> (stack_element A). (* (C:s) : (avec_code C s)*)

Definition stack (A : Set) := (list (stack_element A)).

Inductive cam_reduction (A : Set) : (stack A) -> (code A) -> (stack A) -> (code A) -> Prop :=
| reduc_fst : forall (s t : (stack_element A)) (S S' : (stack A)) (C : (code A)),
		S' = (s::S) -> (cam_reduction A) (((paire A) s t)::S) ((fst A)::C) S' C
| reduc_snd : forall (s t : (stack_element A)) (S S' : (stack A)) (C : (code A)),
		S' = (t::S) -> (cam_reduction A) (((paire A) s t)::S) ((snd A)::C) S' C
| reduc_quote : forall (s : (stack_element A)) (S S' : (stack A)) (C : (code A)) (c : A),
		S' = (((constante A) c)::S) -> (cam_reduction A) (s::S) (((quote A) c)::C) S' C
| reduc_cur : forall (s : (stack_element A)) (S S' : (stack A)) (C C1 : (code A)),
		S' = (((avec_code A) C s)::S) -> (cam_reduction A) (s::S) (((cur A) C)::C1) S' C1
| reduc_push : forall (s : (stack_element A)) (S S' : (stack A)) (C C' :(code A)), 
		S' = (s::s::S) -> (cam_reduction A) (s::S) ((push A)::C) S' C
| reduc_swap : forall (s t : (stack_element A)) (S S' : (stack A)) (C:(code A)), 
		S' = (s::t::S) -> (cam_reduction A) (t::s::S) ((swap A)::C) S' C
| reduc_cons : forall (s t : (stack_element A)) (S S' : (stack A)) (C:(code A)), 
		S' = (((paire A) s t)::S) -> (cam_reduction A) (t::s::S) ((cons A)::C) S' C
| reduc_app : forall (s t : (stack_element A)) (S S' : (stack A)) (C C1 : (code A)), 
		S' = (((paire A) s t)::S) -> (cam_reduction A) (t::((avec_code A) C s)::S) ((app A)::C1) S' (C++C1) (*Ici faut-il aussi remplacer (C++C1) par C' et mettre quelque chose de similaire à S'*).

Lemma pourFst:
	forall (s t : (stack_element nat)) (S S' : (stack nat)) (C : (code nat)),
	(cam_reduction nat) (((paire nat) s t)::S) ((fst nat)::C) (s::S) C.
Proof.
intros.
apply reduc_fst.
trivial.
Qed.

Lemma pourSnd:
	forall (s t : (stack_element nat)) (S S' : (stack nat)) (C : (code nat)),
	(cam_reduction nat) (((paire nat) s t)::S) ((snd nat)::C) (t::S) C.
Proof.
intros.
apply reduc_snd.
trivial.
Qed.

Lemma pourQuote :
	forall (S : (stack nat)) (C : (code nat)) (s : (stack_element nat)), 
	(cam_reduction nat) (s::S) ((quote nat) 0::C) ((constante nat) 0::S) C.
Proof.
intros.
apply reduc_quote.
trivial.
Qed.

Lemma pourCur :
	forall (S : (stack nat)) (C C1 : (code nat)) (s : (stack_element nat)), 
	(cam_reduction nat) (s::S) (((cur nat) C)::C1)  (((avec_code nat) C s)::S) C1.
Proof.
intros.
apply reduc_cur.
trivial.
Qed.

Lemma pourPush :
	forall (S : (stack nat)) (C : (code nat)) (s : (stack_element nat)), 
	(cam_reduction nat) (s::S) ((push nat)::C) (s::s::S) C.
Proof.
intros.
apply reduc_push.
trivial.
trivial.
Qed.

Lemma pour_swap : 
	forall (S : (stack nat)) (C : (code nat)) (s1 s2 : (stack_element nat)),
	(cam_reduction nat) (s1::s2::S) ((swap nat)::C) (s2::s1::S) C.
Proof.
intros.
apply reduc_swap.
reflexivity.
Qed.

Lemma pour_cons : 
	forall (S : (stack nat)) (C : (code nat)) (s1 s2 : (stack_element nat)),
	(cam_reduction nat) (s2::s1::S) ((cons nat)::C) (((paire nat) s1 s2)::S) C.
Proof.
intros.
apply reduc_cons.
reflexivity.
Qed.

Lemma pourApp :
	forall (S : (stack nat)) (C C1 : (code nat)) (s t : (stack_element nat)),
	(cam_reduction nat) (t::((avec_code nat) C s)::S) ((app nat)::C1) (((paire nat) s t)::S) (C++C1).
Proof.
intros.
apply reduc_app.
trivial.
Qed.

Inductive cam_reduction_ref_trans (A : Set) : (stack A) -> (code A) -> (stack A) -> (code A) -> Prop :=
| reduc_cas_base : forall (S S' : (stack A)) (C C' : (code A)),
	(cam_reduction A) S C S' C' -> (cam_reduction_ref_trans A) S C S' C'
| reduc_ref : forall (S : (stack A)) (C : (code A)),
	(cam_reduction_ref_trans A) S C S C
| reduc_trans : forall (S S' S'' : (stack A)) (C C' C'' :(code A)),
	(cam_reduction_ref_trans A) S C S' C' -> (cam_reduction_ref_trans A) S' C' S'' C'' -> (cam_reduction_ref_trans A) S C S'' C''.

Lemma pourAjoutZero :
	forall (S : (stack nat)) (C : (code nat)) (s : (stack_element nat)), 
	(cam_reduction nat) (s::S) ((push nat)::((quote nat) 0)::C) (((constante nat) 0)::s::S) C.
Proof.
intros.
apply (reduc_trans ((cam_reduction_ref_trans nat) (s::S) ((push nat)::((quote nat) 0)::C) (s::s::S) (((quote nat) 0)::C))).