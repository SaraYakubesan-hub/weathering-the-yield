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
| A03 | Abstract | Consider adding a brief statement that Linear Regression Group 3 was formally selected and locked before the final holdout was accessed. | Final-Draft Enhancement | No | Complete | Clarified in the abstract that Linear Regression Group 3 was formally selected and locked before evaluation on the previously unused 2022–2025 final holdout. |
| A04 | Introduction | Preserve the distinction between predictive association and causal inference. | Preserve | No | Ongoing | Reviewed the revised manuscript for predictive versus causal framing. The study continues to describe weather variables as predictive or associational rather than causal, so no substantive wording changes were required. |
| A05 | Literature Review | Verify recent 2025 and 2026 publication details and numerical claims against the original sources. | Final-Draft Correction | No | Complete | Audited all eight 2025–2026 sources cited in the thesis against the original articles and current publication records. Publication details and thesis claims were verified. No substantive corrections to the manuscript were required. |
| A06 | Literature Review | Review research-gap statements and qualify them where appropriate with wording such as “among the studies reviewed” rather than implying an exhaustive review of all published literature. | Final-Draft Correction | No | Complete | Reviewed research-gap and literature-synthesis language for scope. Revised broad references to the literature to explicitly tie conclusions and the central research-gap statement to the studies reviewed in this thesis. The underlying research gap and interpretation were retained.
| A07 | Methods / Data Sources | Add formal citations and reference entries for USDA NASS Quick Stats and NOAA nClimGrid Daily data. | Final-Draft Correction | No | Complete | Verified the primary USDA NASS Quick Stats and NOAA nClimGrid-Daily data sources and added formal in-text and reference-list citations. The NOAA dataset DOI listed by NCEI did not resolve reliably during verification, so the working official NOAA nClimGrid-Daily product page was used in the reference entry instead. |
| A08 | Methods / Software | Add formal citations and reference entries for EpiNOAA, R, `ranger`, and XGBoost. | Final-Draft Correction | No | Complete | Verified and added formal citations for EpiNOAA, R, ranger, and XGBoost using authoritative software, package, and publication sources. The R citation year was finalized after confirming that the project environment used R version 4.5.0, released in 2025. |
| A09 | Methods / Reproducibility | Document the actual R and relevant package versions used for the finalized workflow. | Final-Draft Correction | No | Complete | Completed a final software-version audit of the thesis R environment. Recorded R 4.5.0 and the primary package versions used in the workflow: tidyverse 2.0.0, lubridate 1.9.4, EpiNOAA 1.0.0, ranger 0.18.0, xgboost 3.2.1.1, and maps 3.4.3. Added the software and package versions to the Software and Reproducibility section and preserved the version information in the reproducibility materials. |
| A10 | Methods / Reproducibility | Identify the random seeds used in the modeling workflow and state them in the manuscript or clearly identify where they are documented in the reproducibility materials. | Final-Draft Correction | No | Complete | Verified random-seed handling in the Random Forest and XGBoost workflows. Both analyses use a base seed of 492 with deterministic fold-specific seeds for nested tuning and outer-validation fitting. Updated the Software and Reproducibility section to report the base seed and identify Scripts 18 and 19 as the authoritative record of the exact seed calculations; XGBoost single-thread execution was also documented. |
| A11 | Methods / XGBoost | Clarify how county identity was encoded for XGBoost and describe the construction of the model matrix or equivalent encoding process. | Final-Draft Enhancement | No new modeling | Complete | Verified the XGBoost county-identity encoding in Script 19. Added Methods language explaining that county FIPS was assigned training-defined factor levels and expanded into indicator variables in the numeric model matrix, with matching predictor columns verified between training and validation matrices. |
| A12 | Methods / Nested Tuning | Clarify how unseen or infrequently represented county levels were handled during nested tuning, including the existing exclusion of inner-validation observations whose counties were absent from the corresponding inner-training period. | Final-Draft Enhancement | No new modeling | Complete | Verified county-level handling during nested Random Forest and XGBoost tuning. Training-defined county levels were used within each inner fold; observations from counties not yet represented in the corresponding training period were excluded only from that affected tuning fold. Counties already represented in training were retained regardless of prior observation frequency, with no minimum-frequency threshold. Outer validation and final holdout safeguards confirmed that evaluated counties had prior training representation. |
| A13 | Results / Model Interpretation | Create a supplementary or appendix table containing coefficient estimates and confidence intervals for the final locked Linear Regression Group 3 model. | Final-Draft Enhancement | Yes – descriptive/inferential output from locked model | Complete | Extracted all 102 coefficients from the saved locked Linear Regression Group 3 model without refitting or modifying the specification. Preserved the complete coefficient set in the reproducibility outputs and created a compact table of the 12 non-county terms with model-based 95% OLS confidence intervals for inclusion in Appendix B. Added a Results cross-reference and retained predictive rather than causal interpretation. |
| A14 | Results / Performance Uncertainty | Evaluate a year-level or county-clustered bootstrap approach for uncertainty estimates around major pooled development and final holdout performance measures. | Evaluate Feasibility | Yes | Complete | Assessed uncertainty in the selected model’s predictive-performance measures using 2,000 county-clustered bootstrap resamples of the existing out-of-time predictions. The procedure preserved repeated observations within counties and did not refit or modify the selected model. Added percentile-based 95% bootstrap intervals for development-validation and final-holdout RMSE, MAE, and R², with an explicit limitation that shared year-level dependence was not separately accounted for. Results were summarized in Appendix A and cross-referenced in the Results section. | 
| A15 | Results / Residual Diagnostics | Generate and review a residual-versus-predicted diagnostic for the selected locked linear model. | Final-Draft Enhancement | Yes – diagnostic only | Complete | Created residual-versus-predicted diagnostics for both the locked final model fit on the 2001–2021 development data and the 2022–2025 final holdout. The final fixed-scale diagnostic showed residuals generally centered near zero across the primary development prediction range, with curvature concentrated at very low predicted yields, and a mild downward residual pattern across the holdout prediction range. Holdout RMSE remained relatively stable across predicted-yield quintiles, with no pronounced visual funnel pattern. Results were retained as descriptive diagnostics without changing the locked model. | 
| A16 | Results / Residual Diagnostics | Evaluate influential county-year observations, heteroscedasticity, and evidence of systematic nonlinear residual patterns. | Final-Draft Enhancement | Yes – diagnostic only | Complete | Completed post-selection influence, heteroscedasticity, and nonlinear-pattern diagnostics for the locked Linear Regression Group 3 model. Influence screening identified 94 observations above the descriptive 4/n Cook’s-distance threshold, 16 high-leverage observations, and 25 observations with absolute standardized residuals greater than 3. Influence was concentrated primarily in the difficult 2012 and 2015 growing seasons. The maximum leverage of 1.000 was traced to Brown County, which had only one eligible development observation, while other elevated-leverage cases were associated primarily with counties having shorter eligible histories. Residual variability was greater at very low fitted yields, with a largest-to-smallest fitted-quintile residual-SD ratio of 1.558, but was comparatively stable through the main fitted range. Residual-versus-predictor diagnostics showed some nonlinear structure, particularly near sparsely represented predictor extremes. These findings were documented as model limitations and did not result in removal of observations, refitting, or modification of the formally locked model. | 
| A17 | Results / Prediction Intervals | Determine whether individual county-year prediction intervals can be appropriately calculated and reported under the final model structure. If not included, explain their feasibility and limitations. | Evaluate Feasibility | Possibly | Complete | Completed a post-selection assessment of conventional 95% prediction intervals for the locked Linear Regression Group 3 model using the previously reserved 2022–2025 final holdout. The point predictions exactly reproduced the previously saved holdout predictions. Of 247 holdout observations, 244 fell within the model-based prediction intervals, corresponding to 98.8% empirical coverage. Year-specific coverage ranged from 96.8% to 100%. Mean interval width was 56.85 bushels per acre, indicating substantial uncertainty around individual county-year predictions despite strong empirical coverage. The intervals were retained as descriptive predictive-uncertainty diagnostics and interpreted cautiously because the underlying OLS assumptions were not perfectly satisfied. No model refitting or modification was performed. | 
| A18 | Results / Table 6 | Change the year range to “Pooled 2022–2025” using an en dash. | Final-Draft Correction | No | Complete | Replaced the hyphen in the pooled Table 6 evaluation-period label with an en dash so that “Pooled 2022–2025” is consistent with the table title and thesis date-range formatting. | 
| A19 | Discussion | Add a brief discussion of assumptions associated with the selected linear model, particularly possible within-county and within-year residual dependence. | Final-Draft Enhancement | No | Complete | verified that repeated-county and shared-year dependence are explicitly addressed across the Literature Review, Methods, Study Limitations, and appendix notes. The thesis explains that repeated observations from the same county may share local characteristics, counties within the same growing season may experience common weather conditions, and the effective temporal information is more limited than the county-year observation count alone suggests. The county-cluster bootstrap preserves within-county dependence but does not separately account for shared year-level conditions, and conventional coefficient confidence intervals and prediction intervals are clearly identified as model-based rather than fully dependence-adjusted inferential intervals. No additional manuscript wording was required. | 
| A20 | Discussion | Explain that residual dependence does not invalidate the predictive evaluation but affects how coefficient-level uncertainty should be interpreted. | Final-Draft Enhancement | No | Complete | Added Discussion interpretation distinguishing uncertainty in overall predictive performance from uncertainty in individual county-year predictions. County-clustered bootstrap intervals showed reasonably stable pooled performance estimates under county resampling, while the relatively wide 95% prediction intervals demonstrated that strong aggregate predictive performance does not imply high precision for every individual forecast. | 
| A21 | Conclusion | Preserve the current conclusion that Group 3 provides a useful and interpretable predictive framework rather than a complete or causal representation of corn-yield determination. | Preserve | No | Ongoing | reviewed the Conclusion in light of the added bootstrap uncertainty, residual diagnostics, influence assessment, prediction-interval evaluation, and uncertainty interpretation. The new analyses add appropriate qualification regarding model assumptions and precision for individual county-year predictions but do not alter the study’s primary predictive findings, development-stage model selection, or final-holdout conclusions. The existing Conclusion already appropriately characterizes Linear Regression Group 3 as a useful and interpretable predictive framework rather than a complete or causal representation of corn-yield determinants. No substantive revision was required. | 
| A22 | References | Verify every author name, publication year, title, journal, volume, issue, article number, and DOI against the original publication. | Final-Draft Correction | No | Complete | Verified reference and source metadata across the thesis and corrected identified discrepancies, including the NOAA nClimGrid-Daily dataset citation/DOI, Hewamalage et al. issue number, the accented spelling of Nóia Júnior, and the current USDA NASS Quick Stats URL. Remaining reference work is limited to APA formatting and consistency checks rather than bibliographic-content corrections. | 
| A23 | References | Confirm that all 2026 sources were published and publicly available before final thesis submission. | Final-Draft Correction | No | Complete | independently reverified the publication status and availability of all 2026 scholarly sources cited in the thesis. He and Luo (2026) is published in Sustainability, Li et al. (2026) is published in Agricultural and Forest Meteorology, and Stracqualursi (2026) is available as the Springer version of record in the Journal of Agricultural, Biological and Environmental Statistics. DOI and publication information were confirmed. No unsupported forthcoming or unavailable 2026 sources remain, and no manuscript changes were required. | 
| A24 | References | Confirm that every in-text citation has a corresponding reference entry and every reference-list entry is cited in themanuscript. | Final-Draft Correction | No | Complete | performed a two-way citation crosswalk between the thesis body and the reference list. All 22 reference-list entries are cited in the manuscript, and every author–year citation identified in the manuscript has a corresponding reference-list entry. Group-author and software/data citations were also checked, including USDA NASS, NOAA nClimGrid-Daily, EpiNOAA, R, ranger, and XGBoost. No orphan references, missing references, or citation-year mismatches were identified. | 
| A25 | References / APA | Apply hanging indents consistently and verify APA 7 italics for journal titles and volume numbers. | Final-Draft Correction | No | Complete | Reviewed and standardized the reference list for APA 7 formatting, including journal/volume italics, issue formatting, sentence-case titles, DOI presentation, dataset/software/database formatting, version information, hanging indents, and reference-list spacing. Remaining reference work is limited to final-document QC rather than citation-format corrections. | 
| A26 | Supplementary Materials Link | Rename “Link to the References” to “Supplementary Research and Reproducibility Materials” or another title that accurately describes the linked materials. | Final-Draft Correction | No | Complete | verified that the former “Link to the References” section has been renamed “Supplementary Research and Reproducibility Materials,” with “Reference Materials and Source Documents” used as the descriptive subsection title. The outdated “Link to the References” wording remains only in the currently stale Table of Contents and will be corrected when the TOC is refreshed during final document QC under A36. | 
| A27 | Tables | Standardize spacing between every table number and title. | Final-Draft Correction | No | Complete | content and table presentation reviewed; no immediate formatting changes required. Table/figure page-break and spacing adjustments, including Table 1 pagination, are deferred to final document QC after all content edits are complete. | 
| A28 | Tables | Italicize table titles consistently and apply consistent title capitalization. | Final-Draft Correction | No | Complete | Reviewed table and figure caption formatting throughout the manuscript. Verified that titles use italicized Title Case and standardized table/figure labels to bold formatting. Corrected Table 6 and the Appendix A–C table/figure labels for consistency with APA-style presentation. | 
| A29 | Tables / Figures | Confirm that every table and figure is introduced in the narrative before it appears. | Final-Draft Correction | No | Complete | verified that all main-text tables and figures are introduced in the narrative before they appear. Added brief introductory sentences for Appendix A Table A1, Appendix B Table B1, and Appendix C Table C1, along with a collective introduction for Figures C1–C5, so the appendix tables and figures are also explicitly introduced before presentation. Final spacing and pagination remain deferred to the end-of-document formatting review. | 
| A30 | Tables / Figures | Define abbreviations such as RMSE, MAE, and FIPS in table or figure notes where needed. | Final-Draft Correction | No | Complete | Standardized abbreviation definitions across the abstract, tables, figures, and appendix notes. Expanded USDA NASS, NOAA, RMSE, and MAE at first use in the abstract and added self-contained definitions for RMSE, MAE, R², CI, OLS, SD, and n where relevant in displayed tables and figures. | 
| A31 | Tables | Standardize decimal precision across related results tables. | Final-Draft Correction | No | Complete | Standardized decimal precision across performance metrics, bootstrap intervals, spatial summaries, and coefficient tables. RMSE, MAE, yield-based quantities, residuals, and interval widths were aligned to two decimals; R² to three decimals; percentages to one decimal; and coefficient estimates/confidence intervals to three decimals. Diagnostic statistics retained precision appropriate to their scale. | 
| A32 | Figures | Review and standardize all thesis figures for final-draft readability and presentation. Standardize predictor-group labels and visual treatment across Figures 1–3; review and standardize the facet labels and presentation of Figure 4; retain Figures 5–6 unless consistency issues are identified; and improve Figures 7–8 by enlarging the maps and legends, using a cleaner/lighter background treatment, and displaying counties without eligible observations in medium gray. Preserve the diverging, zero-centered scale in Figure 8. Verify that all figures remain legible at normal Word/PDF viewing size and use consistent caption, label, legend, and text treatment. | Final-Draft Correction | No new analysis | Complete | Standardized and reviewed thesis figures for final-draft readability. Figures 1–3 were updated to use consistent predictor-group labels, line types, symbols, legend placement, and grayscale-friendly styling. Figure 4 was standardized for consistent facet labels and algorithm presentation. Figures 7–8 were enlarged and restyled with clearer county boundaries, white backgrounds, medium-gray no-data counties, larger legends, and a preserved zero-centered diverging scale for RMSE change. Figures 5–6 and Appendix Figures C1–C5 were reviewed and retained without substantive redesign. All figure updates were cosmetic only and did not alter model results or analysis. | 
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
