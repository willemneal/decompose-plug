#lang scribble/base

@(require scriblib/figure
          scribble/manual
          scriblib/footnote
          redex/pict
          slideshow/pict
          "typeset-match-rules.rkt"
          "wfigure.rkt"
          "../sem-sem/patterns.rkt"
          "../sem-sem/non-syntax-directed-match-define-relation.rkt")

@title[#:tag "sec:match-rules"]{A Semantics for Matching}
This section formalizes the notion of matching used in the definitions of
the example reduction systems in @secref{sec:examples}. For ease of 
presentation, we stick to the core language of patterns and terms in
@figure-ref{fig:pat-term}. Redex supports a richer language of patterns
(notably including a notion of Kleene star), 
but this core captures an essence suitable for explaining the semantics
of matching.

@wfigure[#:size 1.7 "fig:pat-term" "Patterns and Terms"]{
@patterns-and-terms
}
Terms @pt[t] are binary trees with atoms as leaves. Atoms @pt[a] include 
literals such as numbers and symbols, as well as the distinguished atom 
@pt[:hole], used in decomposition. Patterns @pt[p] take one of five forms. 
An atomic pattern @pt[a] matches itself. A pattern 
@pt[(:name x p)] binds the pattern variable @pt[x] to the term matched by 
@pt[p]. Repeated pattern variables force the corresponding sub-terms to
be identical. A pattern @pt[(:nt n)] matches terms that match any of the 
productions of the non-terminal @pt[n] (defined outside the pattern). 
We write decomposition patterns @math{p_1[p_2]} using a separate keyword
for clarity: @pt[(:in-hole p_1 p_2)]. Finally, a pattern @pt[(:cons p_1 p_2)] matches 
an interior node, with @pt[p_1] and @pt[p_2] matching the corresponding
subterms.

@(begin
   (require "../2-models/double.rkt"
            "../2-models/models.rkt")
   (define-syntax-rule (check-ok/pt e1 e2)
     (let ([converted (rp->p (lang-nts :arith) 'e1)]
           [qe2 'e2])
       (unless (equal? converted qe2)
         (error '3-semantics.scrbl 
                "example doesn't match:\n  ~s\n  ~s"
                converted
                qe2))
       @pt[e2])))

For example, the left-hand side of the reduction rule in 
@figure-ref{fig:arith} corresponds to the following pattern, 
where the literal @pt[empty] is used for the empty sequence and
the pattern @pt[:number] matches literal numbers:
@centered{@check-ok/pt[(in-hole C (+ number_1 number_2))
                       (:in-hole (:name C (:nt C))
                                 (:cons + 
                                        (:cons (:name number_1 :number)
                                               (:cons (:name number_2 :number)
                                                      empty))))]}

@figure["fig:matching" "Matching and Decomposition"]{
  @(centered combined-matching-rules)
}

@Figure-ref{fig:matching} gives a semantics for patterns via the judgment form
@matches-schema/unframed, which defines when the pattern @pt[p] matches the term
@pt[t]. The grammar @pt[G] is a finite map from non-terminals to sets of patterns. 
The bindings @pt[b] is a finite map from pattern variables to terms shows how the 
pattern variables of @pt[p] can be instantiated to yield @pt[t]. 
A binding map's range may include
not only terms but also encoded contexts @pt[C]. In addition to the tree 
structure represented by a term, an encoded context also defines a path from the
tree's root to one of its possibly many holes---specifically the one exposed by 
decomposition. This path is used to perform nested decompositions (below) and to
instantiate the right-hand sides of reduction rules (@secref{sec:reduction}).

The atom rule produces an empty binding map because a pattern @pt[a] contains no
pattern varibles. The @pt[:name] rule checks that the binding @pt[(pair x t)] is
consistent with the bindings produced by matching @pt[p] against 
@pt[t].@note{Alternatively, one could omit the check and consider patterns 
@pt[(:name x p)] ill-formed when @pt[p] binds @pt[x], since such patterns are 
not useful with finite terms.} With one small exception (explained below), 
@pt[⊔] is the usual least upper bound of finite maps. The @pt[nt] rule applies 
if any of the non-terminal's productions match. The scope of a production's 
pattern variables is limited to that production, and consequently, the 
@pt[nt] rule produces an empty binding map. The @pt[:cons] matches the 
sub-terms and their binding consistency. The @pt[:in-hole] rule refers to an 
auxiliary judgment form @decomposes-schema/unframed, which defines when a 
pattern @pt[p] decomposes a term @pt[t] into a context @pt[C] and a sub-term
@pt[t_^′], which should match @pt[p_2] when matching an @pt[:in-hole] pattern.

The @pt[:hole] decomposition rule decomposes @pt[t] into the empty context
and @pt[t] itself. The first of two @pt[:cons] decomposition rules applies
when the decomposition's focus may be placed within the pair's left sub-term.
The defined decomposition highlights the same sub-term @pt[t_1^′] as the
decomposition of @pt[t_1] but places it within the larger context 
@pt[(:left t_2 C)]. The second of the @pt[:cons] decomposition rules does the
same for the pair's right sub-term. The @pt[:nt] decomposition rule propagates
decompositions but, as in the corresponding matching rule, ignores binding maps.

The @pt[:in-hole] decomposition rule performs a nested decomposition. Nested 
decomposition occurs, for example, when decomposing according to 
call-by-need evaluation contexts (@figure-ref{fig:cbn}), due to the production 
that forces argument expressions. The @pt[:in-hole] rule decomposes @pt[t] into
a composed context @pt[(append-contexts C_1 C_2)] and a sub-term @pt[t_^′], 
where @pt[p_1] and @pt[p_2] match @pt[C_1] and @pt[C_2] respectively. If 
contexts were represented as terms without a distinguished hole, then this rule
would have no way to compose @pt[C_1] and @pt[C_2]; with a path-oriented 
representation, however, list concatenation expresses composition.

The @pt[:name] decomposition rule is similar to the corresponding matching rule,
but it introduces bindings to contexts rather than terms. To cope with patterns 
like this one:
@(centered (pt (:cons (:in-hole (:name C_1 (:nt C)) a)
                      (:name C_1 (:nt C)))))
in which a successful match would simultaneously bind the same pattern variable 
to a context and a term, the definition of @pt[⊔] 
(@figure-ref{fig:binding-consistency}) equates contexts with their unencoded 
representation as terms (produced by @pt[uncontext]). Because the right-hand
side of reduction rule may plug the value bound to such a variable, @pt[⊔] 
prefers contexts (see @pt[merge-value]), since they the path to the hole.
@Secref{sec:reduction} considers an alternative definition of reduction that
avoids this necessity.

@figure["fig:binding-consistency" "The least upper bound of bindings. Cases apply in order."]{
  Remove!
}