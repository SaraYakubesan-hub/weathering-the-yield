# Final Thesis Working Plan

## Weathering the Yield: Predicting Indiana Corn Yield with Growing-Season Weather Extremes

**Student:** Sara Yakubesan  
**Course:** INFO-I 492 Senior Thesis  
**Advisor:** Dr. Sridhar Ramachandran  
**Working Plan Created:** October 2026  
**Project Phase:** Final Revision and Course Completion

---

## Purpose of This Document

This working plan was created following submission of the first thesis draft and required supplementary materials. Its purpose is to organize the remaining work for INFO-I 492, document progress toward the final thesis submission, and provide a clear plan for completing the remaining course requirements.

The document will be updated throughout the remainder of the semester as advisor feedback is received and major project milestones are completed. It is intended to serve as a living project-management record rather than as part of the thesis manuscript itself.

---

## Current Project Status

The primary analytical phase of the thesis project is complete.

Completed work includes:

- Development and auditing of the USDA NASS corn-yield dataset
- Retrieval and processing of NOAA nClimGrid Daily weather data through EpiNOAA
- Historical-yield baseline development
- Conventional and extreme-weather feature engineering
- Multicollinearity assessment and feature refinement
- Comparison of Linear Regression, Random Forest, and XGBoost models
- Expanding-window rolling-origin validation for 2012–2021
- Difficult-year diagnostic analysis
- Formal development-stage model selection and lock
- Final evaluation using the previously reserved 2022–2025 holdout period
- Development-stage county-level spatial error diagnostic
- Completion and submission of the first thesis draft
- Completion and submission of the required first-draft supplementary-material package

The selected final model is Linear Regression with Group 3 predictors, consisting of the historical baseline, conventional growing-season weather variables, and the retained extreme-weather indicators.

The project has now transitioned from the primary analysis phase into the final revision, communication, and course-completion phase.

---

## Remaining Work

The remaining work is organized into the following areas:

1. Final thesis revision
2. Final supplementary materials
3. Weekly Status Reports 6–10
4. Final narrated thesis presentation
5. End-of-semester final assignment
6. Final repository and reproducibility review
7. Course-completion quality-control checks

Detailed plans for each area will be developed and updated in the sections below.

---

## Key Remaining Deadlines

The remaining INFO-I 492 deliverables and major project milestones are summarized below.

| Deliverable | Due Date | Current Status |
|---|---|---|
| Weekly Status Report #6 | October 29, 2026 | In progress |
| Weekly Status Report #7 | November 5, 2026 | Not started |
| Weekly Status Report #8 | November 12, 2026 | Not started |
| Weekly Status Report #9 | November 19, 2026 | Not started |
| Weekly Status Report #10 | December 3, 2026 | Not started |
| Final Thesis Paper | December 3, 2026 at 5:00 PM | Awaiting first-draft feedback / revision planning |
| Required Final Supplementary Materials | December 3, 2026 at 5:00 PM | First-draft package completed; final package will be updated after revisions |
| Final Thesis Narrated Presentation | December 10, 2026 at 5:00 PM | Planning not yet started |
| End-of-Semester Final Assignment | December 17, 2026 at 5:00 PM | Not started |

Scheduling Notes

- No weekly status report is scheduled for November 26 because of the Thanksgiving break.
- The Final Thesis Paper and required final supplementary-material package are due on the same date.
- The final supplementary package will use the required "Final_Theis_Submission_[YourName]" folder and ZIP naming convention.
- The narrated thesis presentation must be between 40 and 60 minutes and include narration for each slide.
- Canvas indicates that work on the End-of-Semester Final Assignment should begin in parallel.
- The End-of-Semester Final Assignment is a required Data Science program exit assessment even though it is listed as a 0-point assignment.
- The current Canvas due date of December 17, 2026 at 5:00 PM is being used for planning. 

---

## Final Thesis Revision Plan

The first thesis draft was submitted with the primary analysis complete. Final-draft work will focus on incorporating advisor feedback, improving presentation and clarity, and completing final quality-control checks. The completed analytical workflow and final model will remain unchanged unless advisor feedback identifies a substantive methodological or analytical issue that requires correction.

### Awaiting Advisor Feedback

- [ ] Review all feedback provided by Dr. R on the first thesis draft.
- [ ] Organize feedback by manuscript section.
- [ ] Identify required revisions and distinguish them from optional recommendations.
- [ ] Revise the manuscript in response to advisor feedback.
- [ ] Verify that all advisor comments have been addressed before final submission.
- [ ] Document major revision decisions in the project repository where appropriate.

### Revisions Already Identified

The following improvements were intentionally deferred from the first-draft submission and are planned for the final draft.

#### Figures 1–3

- [ ] Standardize predictor-group wording across the Linear Regression, Random Forest, and XGBoost figures.
- [ ] Use consistent labels:
  - Group 1 – Historical baseline
  - Group 2 – Historical + conventional weather
  - Group 3 – Historical + conventional + extremes
- [ ] Confirm consistent legend formatting and overall visual presentation.

#### Figure 4

- [ ] Standardize predictor-group facet labels to G1, G2, and G3.
- [ ] Confirm that the figure remains clear when viewed at manuscript size.

#### Figures 5–6

- [ ] Review final holdout figures for consistency with the other thesis figures.
- [ ] Make changes only if needed for visual consistency or advisor feedback.

#### Figures 7–8

- [ ] Improve figure size and readability.
- [ ] Improve legend readability and visual balance.
- [ ] Use a light, publication-friendly background.
- [ ] Display counties without eligible validation observations consistently in medium gray.
- [ ] Preserve the diverging scale centered at zero in the county RMSE-reduction map.

### Manuscript Quality-Control Review

After advisor-directed revisions and figure updates are complete:

- [ ] Confirm that the abstract remains between 150 and 250 words.
- [ ] Verify that the research question and hypothesis are stated clearly and consistently.
- [ ] Confirm that the Introduction, Literature Review, Methods, Results, Discussion, Conclusion, and Future Directions remain internally consistent.
- [ ] Confirm that predictive results are not described using unsupported causal language.
- [ ] Verify that all numerical results in the text match the final analytical outputs.
- [ ] Verify that figure numbering, captions, and in-text figure references are correct.
- [ ] Perform a final APA in-text citation audit.
- [ ] Perform a final APA reference-list audit.
- [ ] Confirm that every cited source appears in the reference list and every listed reference is cited in the manuscript.
- [ ] Confirm that literature used for the thesis continues to meet course source-date requirements.
- [ ] Review headings, spacing, font, page numbering, and other formatting using the required thesis template.
- [ ] Update the Table of Contents after all revisions are complete.
- [ ] Perform a final spelling, grammar, and readability review.
- [ ] Verify that the final manuscript opens correctly after saving and that all figures and formatting display as intended.

### Final Analysis Integrity Check

Before the final thesis is submitted:

- [ ] Confirm that Linear Regression with Group 3 predictors remains the documented final model unless a correction is required.
- [ ] Confirm that the final 2022–2025 holdout results remain unchanged unless an identified analytical error requires correction.
- [ ] Confirm that no post-holdout tuning or predictor selection has been introduced.
- [ ] Verify that manuscript descriptions remain consistent with the finalized scripts, methodology documentation, and saved outputs.
- [ ] Document any substantive analytical correction made after the first-draft submission, including the reason for the change and its effect on reported results.

### Completion Criteria

The Final Thesis Revision Plan will be considered complete when:

- all advisor feedback has been addressed,
- all planned figure improvements have been completed,
- manuscript content and numerical results have been verified,
- APA and template formatting have been audited,
- the Table of Contents has been updated,
- and the manuscript is ready for the December 3, 2026 final submission.

---

## Final Supplementary Materials Plan

*To be completed.*

---

## Narrated Presentation Plan

*To be completed.*

---

## End-of-Semester Assignment Plan

*To be completed.*

---

## Weekly Work Plan

*To be completed.*

---

## Deferred Improvements

*To be completed.*

---

## Progress Log

*To be updated as major milestones are completed.*
