# Advisor Feedback Action Plan

**Project:** Weathering the Yield: Predicting Indiana Corn Yield with Growing-Season Weather Extremes  
**Course:** INFO-I 492 Senior Thesis  
**Advisor:** Dr. Sridhar Ramachandran  
**Feedback Received:** October 25, 2026  
**Revision Phase:** Final Thesis Draft

---

## Purpose

This document converts the feedback received on the first thesis draft into a structured revision plan for the final paper.

The first draft received a score of 100/100, with a diagnostic rubric score of 97/100 identifying areas that could be strengthened before 
the final submission. The advisor indicated that the remaining revisions are primarily related to citations, reproducibility documentation, 
uncertainty reporting, statistical diagnostics, and APA/formatting refinements rather than major conceptual changes to the study.

The existing model-development process, selected Linear Regression Group 3 specification, development-stage validation framework, formal 
model lock, final holdout evaluation, difficult-year diagnostic, and spatial diagnostic will remain unchanged unless a substantive error is 
identified during final review.

No additional model selection, predictor selection, hyperparameter tuning, or post-holdout optimization will be performed as part of these revisions.

---

## Revision Priority Categories

**Final-Draft Correction**  
A specific issue identified by the advisor that should be corrected before final submission.

**Final-Draft Enhancement**  
A recommended addition that directly strengthens the thesis and should be incorporated where feasible.

**Evaluate Feasibility**  
A more substantial analytical addition that should be investigated before deciding whether it belongs in the final thesis, supplementary materials, 
or later publication work.

**Preserve**  
A feature of the existing manuscript that the advisor specifically identified as a strength and that should not be weakened during revision.

---

## Advisor Feedback Action Tracker

| ID | Thesis Area | Planned Action | Priority | New Analysis Required? | Status | Outcome / Verification Notes |
|---|---|---|---|---|---|---|
| A01 | Title Page | Confirm whether institutional affiliation should be included under the course template or APA student-paper requirements. | Final-Draft Correction | No | Complete | Verified the current IU Southeast academic affiliation using the 2026–2027 Academic Bulletin. Updated the title page affiliation to School of Natural Sciences, Indiana University Southeast. |
| A02 | Title Page | Change the title-page date from blue to standard black text and verify spacing and alignment. | Final-Draft Correction | No | Complete | Updated the title-page date to standard black text and reviewed the page for spacing and alignment. The existing course-template layout was retained, with the final submission date to be updated before the December submission. |
| A03 | Abstract | Consider adding a brief statement that Linear Regression Group 3 was formally selected and locked before the final holdout was accessed. | Final-Draft Enhancement | No | Not Started |
| A04 | Introduction | Preserve the distinction between predictive association and causal inference. | Preserve | No | Ongoing |
| A05 | Literature Review | Verify recent 2025 and 2026 publication details and numerical claims against the original sources. | Final-Draft Correction | No | Complete | Audited all eight 2025–2026 sources cited in the thesis against the original articles and current publication records. Publication details and thesis claims were verified. No substantive corrections to the manuscript were required. |
| A06 | Literature Review | Review research-gap statements and qualify them where appropriate with wording such as “among the studies reviewed” rather than implying an exhaustive review of all published literature. | Final-Draft Correction | No | Complete | Reviewed research-gap and literature-synthesis language for scope. Revised broad references to the literature to explicitly tie conclusions and the central research-gap statement to the studies reviewed in this thesis. The underlying research gap and interpretation were retained.
| A07 | Methods / Data Sources | Add formal citations and reference entries for USDA NASS Quick Stats and NOAA nClimGrid Daily data. | Final-Draft Correction | No | Complete | Verified the primary USDA NASS Quick Stats and NOAA nClimGrid-Daily data sources and added formal in-text and reference-list citations. The NOAA dataset DOI listed by NCEI did not resolve reliably during verification, so the working official NOAA nClimGrid-Daily product page was used in the reference entry instead. |
| A08 | Methods / Software | Add formal citations and reference entries for EpiNOAA, R, `ranger`, and XGBoost. | Final-Draft Correction | No | Not Started |
| A09 | Methods / Reproducibility | Document the actual R and relevant package versions used for the finalized workflow. | Final-Draft Correction | No | Not Started |
| A10 | Methods / Reproducibility | Identify the random seeds used in the modeling workflow and state them in the manuscript or clearly identify where they are documented in the reproducibility materials. | Final-Draft Correction | No | Not Started |
| A11 | Methods / XGBoost | Clarify how county identity was encoded for XGBoost and describe the construction of the model matrix or equivalent encoding process. | Final-Draft Enhancement | No new modeling | Not Started |
| A12 | Methods / Nested Tuning | Clarify how unseen or infrequently represented county levels were handled during nested tuning, including the existing exclusion of inner-validation observations whose counties were absent from the corresponding inner-training period. | Final-Draft Enhancement | No new modeling | Not Started |
| A13 | Results / Model Interpretation | Create a supplementary or appendix table containing coefficient estimates and confidence intervals for the final locked Linear Regression Group 3 model. | Final-Draft Enhancement | Yes – descriptive/inferential output from locked model | Not Started |
| A14 | Results / Performance Uncertainty | Evaluate a year-level or county-clustered bootstrap approach for uncertainty estimates around major pooled development and final holdout performance measures. | Evaluate Feasibility | Yes | Not Started |
| A15 | Results / Residual Diagnostics | Generate and review a residual-versus-predicted diagnostic for the selected locked linear model. | Final-Draft Enhancement | Yes – diagnostic only | Not Started |
| A16 | Results / Residual Diagnostics | Evaluate influential county-year observations, heteroscedasticity, and evidence of systematic nonlinear residual patterns. | Final-Draft Enhancement | Yes – diagnostic only | Not Started |
| A17 | Results / Prediction Intervals | Determine whether individual county-year prediction intervals can be appropriately calculated and reported under the final model structure. If not included, explain their feasibility and limitations. | Evaluate Feasibility | Possibly | Not Started |
| A18 | Results / Table 6 | Change the year range to “Pooled 2022–2025” using an en dash. | Final-Draft Correction | No | Not Started |
| A19 | Discussion | Add a brief discussion of assumptions associated with the selected linear model, particularly possible within-county and within-year residual dependence. | Final-Draft Enhancement | No | Not Started |
| A20 | Discussion | Explain that residual dependence does not invalidate the predictive evaluation but affects how coefficient-level uncertainty should be interpreted. | Final-Draft Enhancement | No | Not Started |
| A21 | Conclusion | Preserve the current conclusion that Group 3 provides a useful and interpretable predictive framework rather than a complete or causal representation of corn-yield determination. | Preserve | No | Ongoing |
| A22 | References | Verify every author name, publication year, title, journal, volume, issue, article number, and DOI against the original publication. | Final-Draft Correction | No | Not Started |
| A23 | References | Confirm that all 2026 sources were published and publicly available before final thesis submission. | Final-Draft Correction | No | Not Started |
| A24 | References | Confirm that every in-text citation has a corresponding reference entry and every reference-list entry is cited in themanuscript. | Final-Draft Correction | No | Not Started |
| A25 | References / APA | Apply hanging indents consistently and verify APA 7 italics for journal titles and volume numbers. | Final-Draft Correction | No | Not Started |
| A26 | Supplementary Materials Link | Rename “Link to the References” to “Supplementary Research and Reproducibility Materials” or another title that accurately describes the linked materials. | Final-Draft Correction | No | Not Started |
| A27 | Tables | Standardize spacing between every table number and title. | Final-Draft Correction | No | Not Started |
| A28 | Tables | Italicize table titles consistently and apply consistent title capitalization. | Final-Draft Correction | No | Not Started |
| A29 | Tables / Figures | Confirm that every table and figure is introduced in the narrative before it appears. | Final-Draft Correction | No | Not Started |
| A30 | Tables / Figures | Define abbreviations such as RMSE, MAE, and FIPS in table or figure notes where needed. | Final-Draft Correction | No | Not Started |
| A31 | Tables | Standardize decimal precision across related results tables. | Final-Draft Correction | No | Not Started |
| A32 | Figures | Review all figures at normal Word-document viewing size and improve legibility where needed. | Final-Draft Correction | No new analysis | Not Started |
| A33 | Formatting | Use en dashes consistently for year ranges throughout the manuscript. | Final-Draft Correction | No | Not Started |
| A34 | Formatting | Review whether numbered headings are required by the provided course template. If not required, verify consistent APA heading levels. | Final-Draft Correction | No | Not Started |
| A35 | End Matter | Remove the unexplained “2” appearing after the supplementary-materials link. | Final-Draft Correction | No | Not Started |
| A36 | Table of Contents | Update the Table of Contents only after all substantive and formatting revisions are complete. | Final-Draft Correction | No | Not Started |
| A37 | Entire Manuscript | Preserve the distinction between development-stage validation and the previously untouched final 2022–2025 holdout evaluation. | Preserve | No | Ongoing |
| A38 | Entire Manuscript | Preserve the distinction between prediction, association, and causal inference throughout all new or revised text. | Preserve | No | Ongoing |

---

## Analytical Revision Guardrails

Any additional analyses completed in response to advisor feedback will be treated as **diagnostic, uncertainty, or interpretive extensions of the 
already locked final model**.

The following decisions will remain fixed:

- Selected algorithm: Linear Regression
- Selected predictor group: Group 3
- Development period: 2001–2021
- Final holdout period: 2022–2025
- Primary predictor set
- Exclusion of E01 hot-day count from the primary specification
- Completed development-stage model comparison
- Completed difficult-year diagnostic
- Completed final holdout evaluation
- Completed development-stage spatial diagnostic

Additional residual diagnostics, coefficient summaries, confidence intervals, bootstrap uncertainty estimates, or prediction-interval investigations 
will not be used to retrospectively select a different model or optimize the existing specification.

If any new diagnostic identifies a substantive analytical error rather than a normal model limitation, that issue will be documented separately 
before any corrective action is taken.

---

## Recommended Revision Sequence

### Phase 1 – Advisor Feedback Review and Source Verification

- Verify all advisor comments against the current thesis draft.
- Confirm all 2025 and 2026 literature sources against original publications.
- Audit numerical claims tied to recent literature.
- Review and appropriately bound research-gap statements.
- Identify the official citation information for USDA NASS, NOAA nClimGrid, EpiNOAA, R, `ranger`, and XGBoost.

### Phase 2 – Reproducibility and Methods Updates

- Add dataset and software citations.
- Record software and package versions.
- document random-seed information.
- Clarify XGBoost county encoding.
- Clarify handling of unseen county levels during nested tuning.
- Review the Methods section for any other reproducibility details affected by these additions.

### Phase 3 – Final-Model Statistical Additions

- Produce the final locked-model coefficient and confidence-interval table.
- Generate residual-versus-predicted diagnostics.
- Evaluate influential observations, heteroscedasticity, and nonlinear residual patterns.
- Evaluate appropriate uncertainty estimation for pooled development and holdout performance.
- Evaluate whether county-year prediction intervals can be appropriately reported.
- Decide which outputs belong in the main thesis, appendix, supplementary materials, or later publication manuscript.

### Phase 4 – Discussion and Interpretation Updates

- Add discussion of linear-model assumptions.
- Address possible within-county and within-year residual dependence.
- Clarify implications for coefficient-level uncertainty.
- Incorporate any relevant findings from the additional diagnostics without changing the locked predictive model.
- Preserve the existing noncausal interpretation.

### Phase 5 – Tables, Figures, References, and APA Cleanup

- Standardize table numbering, title spacing, italics, capitalization, and decimal precision.
- Add needed abbreviation notes.
- Standardize year ranges using en dashes.
- Complete deferred figure-readability improvements.
- Confirm that all tables and figures are introduced before appearing.
- Complete the citation/reference cross-check.
- Apply hanging indents and APA reference formatting.
- Correct title-page formatting.
- Rename the supplementary-materials link.
- Remove the unexplained end-of-document “2.”

### Phase 6 – Final Document Quality Control

- Review the Abstract after all substantive revisions.
- Verify the Introduction and Conclusion still align with the final results.
- Confirm that development-stage and holdout terminology remains consistent.
- Verify that no new language implies causality.
- Update the Table of Contents.
- Perform a final page-by-page formatting review.
- Perform a final numerical consistency check.
- Compare the finished paper against each item in this action plan.
- Prepare the final thesis and final supplementary-material package for submission.

---

## Publication-Related Considerations

The advisor indicated that the thesis has potential for development into a joint journal publication, with Sara Yakubesan as first author and 
Dr. Ramachandran as second author.

Publication preparation will be treated as a related but separate workstream from the requirements of the INFO-I 492 final thesis.

Analytical additions that strengthen both the final thesis and a future journal submission may be completed during the remaining semester where 
feasible. More extensive publication-specific changes can continue after the course requirements are satisfied.

Potential publication-strengthening items from the current advisor feedback include:

- uncertainty estimates for predictive performance
- coefficient estimates and confidence intervals
- expanded residual diagnostics
- prediction intervals
- more detailed discussion of dependence and linear-model assumptions
- comprehensive verification and citation of data and software sources

---

## Week 7 Objective

Week 7 will focus on converting first-draft feedback into controlled final-thesis revisions.

The immediate priorities are to complete the advisor-feedback audit, begin source and reference verification, document the additional 
reproducibility information requested in the Methods section, and determine the scope of the additional statistical diagnostics.

The final model-selection process will remain closed while these revisions are completed.
