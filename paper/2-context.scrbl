#lang scribble/base

@(require redex/pict
          redex/reduction-semantics
          (only-in scribble/core table paragraph style element)
          (only-in slideshow/pict vl-append)
          "2-models/model.rkt"
          "2-models/util.rkt"
          "wfigure.rkt"
          "citations.rkt")


@title{Matching and Contexts}

@wfigure["fig:arith" "Arithmetic Expressions"]{
@(render-language arith)

@(render-language arith/red)

@paragraph[(style "vspace" '()) '(".1in")]

@(render-reduction-relation arith-red)
}

This section introduces the notion of a context and explains, through a series of examples, how pattern matching for contexts works.
In its essence, a pattern of the form @rr[(in-hole C e)] matches an expression when the expression can be split into two parts,
an outer part (the context) that matches @rr[C] and an inner part that matches @rr[e]. The outer part also marks where the inner
part appears with a hole, written @rr[hole]. In other words, if you think of an expression as a tree, matching against
@rr[(in-hole C e)] finds some subtree of the expression that matches @rr[e], and then replaces that subterm with the hole
to build a new expression in such a way that that new expression matches @rr[C].

To get warmed up, consider @figure-ref["fig:arith"]. In this language @rr[a] matches addition expressions and @rr[C] matches
addition expressions with a hole at any subexpression. (The ellipses are our notation for the Kleene star operator, allowing
whatever appears before the ellipsis to match as many or as few times as necessary.)
For example, the expression @rr[(+ 1 2)] matches  @rr[(in-hole C a)] three ways:
@centered{
@table[(style #f '())
       (list (list @paragraph[(style #f '()) @list{@rr[C] = @rr[hole]}]
                   @paragraph[(style "hspace" '())]{.1in}
                   @paragraph[(style #f '()) @list{@rr[a] = @rr[(+ 1 2)]}])
             (list @paragraph[(style #f '()) @list{@rr[C] = @rr[(+ hole 2)]}]
                   @paragraph[(style "hspace" '())]{.1in}
                   @paragraph[(style #f '()) @list{@rr[a] = @rr[1]}])
             (list @paragraph[(style #f '()) @list{@rr[C] = @rr[(+ 1 hole)]}]
                   @paragraph[(style "hspace" '())]{.1in}
                   @paragraph[(style #f '()) @list{@rr[a] = @rr[2]}]))]}

Accordingly, the reduction relation given in @figure-ref["fig:arith"] reduces addition expressions wherever they appear
in an expression, reducing @rr[(+ (+ 1 2) (+ 3 4))] to both @rr[(+ 3 (+ 3 4))] and @rr[(+ (+ 1 2) 7)].


@wfigure["fig:lc" "λ-calculus"]{
@(vl-append ;; not quite right; we really want to line up with the ::='s in there.
  (render-language Λ #:nts (remove* '(x y) (language-nts Λ)))
  (render-language Λ/red))

@paragraph[(style "vspace" '()) '(".1in")]


@(with-rewriters
  (render-reduction-relation cbv-red))
}

A common use of contexts is to restrict the places where a reduction may occur in order to model 
a realistic programming language's order of evaluation
in the lambda calculus. @Figure-ref["fig:lc"] 
gives a definition of @rr[E] that enforces left-to-right order of evaluation. 
For example, consider this nested set of function calls, 
@rr[((f x) (g x))],
where the result of @rr[(g y)] is passed to the result of @rr[(f x)].
It decomposes into the context
@rr[(hole (g x))]
allowing
evaluation in the first position of the
application,
but not this context
@rr[((f x) hole)].
The second context is not allowed
because the grammar for @rr[E]
allows the hole to appear
in the argument position of
an application expression only when the function
position is already a value. Accordingly,
the reduction system insists that the call
to @rr[f] happens before the call to @rr[g].

@wfigure[#:size 2.2 "fig:cbn" "Call-by-need"]{
@(render-language Λneed/red #:nts '(E))

@(parameterize ([render-reduction-relation-rules '("deref")])
   (render-reduction-relation cbn-red))
}

Contexts can also be used in sophisticated ways to model the call-by-need λ-calculus.
@Figure-ref["fig:cbn"] shows how @citet[cbn-calculus] give a model for call-by-need.
The first two productions of @rr[E] are standard, allowing evaluation wherever @rr[E]
may be, as well as in the function position of an application, regardless of what
appears in the argument position. The third case allows evaluation in the body of
a lambda expression that is in the function position of an application. Intuitively,
this case says that once we have determined that the function to be applied, then
we can begin to evaluate its body. Of course, the function is eventually going to
need its argument and this is where the fourth production comes in. This production
is the most interesting. It says: when the next thing that a function in the function position
of some application does is use its argument, then you may evaluate its argument.

<<need an example reduction sequence here ...>>

Duis hendrerit imperdiet nisl, et interdum orci sollicitudin a. Duis eu lectus justo, at tincidunt libero. Nam tempus rutrum nibh, vitae auctor est rhoncus sed. In justo diam, accumsan nec fermentum id, consectetur eu lectus. Vestibulum libero diam, volutpat at eleifend a, tempus eget ligula. Sed urna libero, eleifend vitae accumsan at, adipiscing et nisi. Morbi tincidunt, lectus ac ullamcorper iaculis, arcu est sagittis massa, bibendum tempus mi diam ac justo. Sed imperdiet velit in quam molestie aliquam. Fusce vitae condimentum elit. Nulla facilisi. Integer scelerisque rutrum dui nec aliquam. In hac habitasse platea dictumst. Donec dictum congue egestas. Nullam non turpis enim, eget gravida odio. In hac habitasse platea dictumst. Morbi nisi enim, cursus nec iaculis blandit, imperdiet sit amet est. Aenean adipiscing faucibus ante non condimentum. Mauris vel mi lectus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque sodales consectetur neque quis mollis.

@wfigure["fig:cont" "Continuations"]{
@(render-language Λk/red)

@(render-reduction-relation cont-red)
}

Duis hendrerit imperdiet nisl, et interdum orci sollicitudin a. Duis eu lectus justo, at tincidunt libero. Nam tempus rutrum nibh, vitae auctor est rhoncus sed. In justo diam, accumsan nec fermentum id, consectetur eu lectus. Vestibulum libero diam, volutpat at eleifend a, tempus eget ligula. Sed urna libero, eleifend vitae accumsan at, adipiscing et nisi. Morbi tincidunt, lectus ac ullamcorper iaculis, arcu est sagittis massa, bibendum tempus mi diam ac justo. Sed imperdiet velit in quam molestie aliquam. Fusce vitae condimentum elit. Nulla facilisi. Integer scelerisque rutrum dui nec aliquam. In hac habitasse platea dictumst. Donec dictum congue egestas. Nullam non turpis enim, eget gravida odio. In hac habitasse platea dictumst. Morbi nisi enim, cursus nec iaculis blandit, imperdiet sit amet est. Aenean adipiscing faucibus ante non condimentum. Mauris vel mi lectus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque sodales consectetur neque quis mollis.

@wfigure["fig:delim" "Delimited Continuations"]{
@(render-language Λdk/red)

@(render-reduction-relation delim-red)
}

In ut ipsum tellus. In quis mauris mi. Nam non lacus ante. Nunc non orci arcu, nec porttitor massa. Donec non nunc leo, a pulvinar mi. Vestibulum aliquam, neque eu mattis ultrices, leo mauris blandit nulla, a ultricies enim urna sit amet justo. Vestibulum mollis lacinia turpis semper malesuada. Quisque ac justo vel turpis ornare convallis. Quisque feugiat purus a nulla euismod vitae blandit ligula hendrerit. Morbi eu purus posuere ligula tincidunt malesuada. Praesent at odio neque. Aenean eu ante et mauris consectetur congue a eu odio. Sed viverra adipiscing accumsan. Cras sapien enim, ultrices non dapibus vitae, tempus vel tortor. Proin imperdiet risus in massa hendrerit condimentum. Nulla rutrum, nulla ut eleifend tincidunt, dui velit suscipit odio, non pharetra est risus sed ligula. Vestibulum nec libero vitae quam bibendum tempus eget in lectus.

In ut ipsum tellus. In quis mauris mi. Nam non lacus ante. Nunc non orci arcu, nec porttitor massa. Donec non nunc leo, a pulvinar mi. Vestibulum aliquam, neque eu mattis ultrices, leo mauris blandit nulla, a ultricies enim urna sit amet justo. Vestibulum mollis lacinia turpis semper malesuada. Quisque ac justo vel turpis ornare convallis. Quisque feugiat purus a nulla euismod vitae blandit ligula hendrerit. Morbi eu purus posuere ligula tincidunt malesuada. Praesent at odio neque. Aenean eu ante et mauris consectetur congue a eu odio. Sed viverra adipiscing accumsan. Cras sapien enim, ultrices non dapibus vitae, tempus vel tortor. Proin imperdiet risus in massa hendrerit condimentum. Nulla rutrum, nulla ut eleifend tincidunt, dui velit suscipit odio, non pharetra est risus sed ligula. Vestibulum nec libero vitae quam bibendum tempus eget in lectus.

In ut ipsum tellus. In quis mauris mi. Nam non lacus ante. Nunc non orci arcu, nec porttitor massa. Donec non nunc leo, a pulvinar mi. Vestibulum aliquam, neque eu mattis ultrices, leo mauris blandit nulla, a ultricies enim urna sit amet justo. Vestibulum mollis lacinia turpis semper malesuada. Quisque ac justo vel turpis ornare convallis. Quisque feugiat purus a nulla euismod vitae blandit ligula hendrerit. Morbi eu purus posuere ligula tincidunt malesuada. Praesent at odio neque. Aenean eu ante et mauris consectetur congue a eu odio. Sed viverra adipiscing accumsan. Cras sapien enim, ultrices non dapibus vitae, tempus vel tortor. Proin imperdiet risus in massa hendrerit condimentum. Nulla rutrum, nulla ut eleifend tincidunt, dui velit suscipit odio, non pharetra est risus sed ligula. Vestibulum nec libero vitae quam bibendum tempus eget in lectus.

@(define-language ex2
   (C (in-hole C (f hole)) hole))
@wfigure["fig:wacky" "Wacky Context"]{
@(render-language ex2)
}
