<!--
IEEE CONFERENCE PAPER — MARKDOWN FORMAT TEMPLATE
=================================================
Purpose: a structural reference for an AI to generate IEEE-style conference
papers. Markdown cannot reproduce IEEE's two-column A4 layout, fonts, or
column-spanning figures — those are the LaTeX/Word template's job. What this
captures is the part an AI needs to get right: section hierarchy, ordering,
author-block layout, abstract/keyword conventions, and IEEE citation/reference
style.

CONVENTIONS ENCODED BELOW
- Top-level sections: numbered with uppercase Roman numerals (I, II, III...),
  heading text in Title Case, styled "Heading 1" in Word.
- Second-level: lettered A, B, C ("Heading 2"), Title Case.
- Third-level: numbered 1), 2) ("Heading 3").
- Fourth-level: lettered a), b) ("Heading 4").
- Abstract and Keywords are run-in heads (bold/italic label, same line).
- Define every abbreviation on first use in the body, even if defined in
  the abstract. Exceptions: IEEE, SI, MKS, CGS, ac, dc, rms.
- Citations: bracketed numerals [1]; punctuation follows the bracket [2].
  Refer to the number alone — "in [3]", not "Ref. [3]" — except sentence-start:
  "Reference [3] was the first...".
- References: give ALL author names unless there are six or more; only then
  use "et al.". In a paper title, capitalize only the first word plus proper
  nouns and element symbols.
- REMOVE all guidance/placeholder text before submission.
-->

# Paper Title
<!-- Title Case. No abbreviations unless unavoidable. No symbols, special
     characters, footnotes, or math in the title. -->

## Authors
<!--
Designed for up to six authors, one required. List left-to-right, then wrap to
the next row (3rd row past 8 authors). Order = future citation order. Do not
group by affiliation. Keep affiliations succinct.
Each author block, five lines:
-->

**1st Given Name Surname**
dept. name of organization (of Affiliation)
name of organization (of Affiliation)
City, Country
email address or ORCID

**2nd Given Name Surname**
dept. name of organization (of Affiliation)
name of organization (of Affiliation)
City, Country
email address or ORCID

---

***Abstract*—** <!-- Run-in head, italic label. -->
A single self-contained paragraph stating problem, approach, and principal
result. No citations, no undefined abbreviations, no math or special
characters. Typically 150–250 words.

***Keywords*—** component, formatting, style, styling, insert
<!-- 3–6 comma-separated terms. -->

---

## I. Introduction

Motivate the problem, state the contribution, and outline the paper. Define
abbreviations on first use here — e.g., signal-to-noise ratio (SNR) — even if
they also appear in the abstract.

## II. Related Work

Position the contribution against prior art. Cite as you go [1], [2]. The
period follows the bracket [3].

## III. Method

Describe the approach in enough detail to reproduce it.

### A. Subsection

Second-level content.

### B. Another Subsection

1) Third-level item: introduced with a numbered run-in head.

2) Second item: parallel structure.

   a) Fourth-level detail: lettered run-in head.

   b) Second detail.

#### Equations

Number equations consecutively, flush right in parentheses. Define every symbol
at or immediately after its first use. Reference as "(1)", not "Eq. (1)" —
except sentence-start: "Equation (1) is...".

$$
a + b = c \tag{1}
$$

## IV. Experiments

State the setup, datasets, metrics, and baselines before results.

### A. Setup

Use SI (MKS) units as primary; English units, if needed, in parentheses. Do not
mix unit systems. Use a leading zero: 0.25, not .25.

### B. Results

<!-- Tables: caption ABOVE the table (IEEE "table head"), Roman-numeral label. -->

**TABLE I. Table Type Styles**

| Table Head | Table Column Head | Subhead | Subhead |
|------------|-------------------|---------|---------|
| copy       | More table copy   |         |         |

<sup>a</sup> Sample of a table footnote.

<!-- Figures: caption BELOW the figure (IEEE "figure caption"). Cite before it
     appears. Use "Fig. 1" even at sentence-start. Axis labels as words, not
     bare symbols: "Magnetization (A/m)", not "M". -->

![Example of a figure caption.](figure1.png)

**Fig. 1.** Example of a figure caption.

## V. Discussion

Interpret results, state limitations, note threats to validity.

## VI. Conclusion

Summarize the contribution and outcome; point to future work. No new results.

## Acknowledgment
<!-- IEEE "Heading 5": unnumbered. American spelling: "Acknowledgment", no "e"
     after the "g". Avoid "one of us (R. B. G.) thanks..."; write "R. B. G.
     thanks...". Put sponsor acknowledgments in a first-page footnote instead. -->

The preferred spelling of the word "acknowledgment" in America is without an
"e" after the "g".

## References
<!--
Unnumbered head. IEEE style, numbered in order of first citation. Give all
author names unless there are six or more (then "et al."). Capitalize only the
first word of a paper title, plus proper nouns and element symbols. Cite
unpublished work as "unpublished" and accepted work as "in press".
-->

[1] G. Eason, B. Noble, and I. N. Sneddon, "On certain integrals of Lipschitz-Hankel type involving products of Bessel functions," *Phil. Trans. Roy. Soc. London*, vol. A247, pp. 529–551, April 1955.

[2] J. Clerk Maxwell, *A Treatise on Electricity and Magnetism*, 3rd ed., vol. 2. Oxford: Clarendon, 1892, pp. 68–73.

[3] I. S. Jacobs and C. P. Bean, "Fine particles, thin films and exchange anisotropy," in *Magnetism*, vol. III, G. T. Rado and H. Suhl, Eds. New York: Academic, 1963, pp. 271–350.

[4] K. Elissa, "Title of paper if known," unpublished.

[5] R. Nicole, "Title of paper with only first word capitalized," *J. Name Stand. Abbrev.*, in press.

[6] D. P. Kingma and M. Welling, "Auto-encoding variational Bayes," 2013, arXiv:1312.6114. [Online]. Available: https://arxiv.org/abs/1312.6114
