# Week 7 Evidence

This folder documents the Week 7 completion of final thesis revision, supplemental appendix and diagnostic analyses, final manuscript quality control, figure standardization, and initial development of the final narrated thesis presentation.

Week 7 included completion of the analytical work required for Appendices A, B, and C; incorporation of advisor feedback into the final thesis; final Word and PDF quality-control review; preparation of standardized thesis figures; and creation of the initial storyline, slide outline, figure-selection plan, and rubric crosswalk for the narrated thesis presentation.

## Appendix Analyses and Final Diagnostic Scripting

Week 7 also included completion of the analytical scripting required for the final thesis appendices and supplemental model-diagnostic reporting.

These analyses were completed after the primary model-development and final-holdout workflow and were used to quantify uncertainty, document the final locked Linear Regression Group 3 model, and evaluate diagnostic behavior without changing the selected specification.

The appendix-related work included:

- creation of county-clustered bootstrap uncertainty estimates for development-stage and final-holdout predictive performance
- calculation of 95% bootstrap intervals for RMSE, MAE, and out-of-sample R²
- extraction and organization of final Linear Regression coefficient estimates and model-based 95% confidence intervals
- residual-versus-fitted assessment
- influence screening using Cook’s distance, leverage, and standardized residuals
- evaluation of residual spread and possible heteroscedasticity
- descriptive assessment of possible nonlinear residual patterns
- generation and evaluation of conventional 95% prediction intervals for the final holdout
- preparation of the tables, figures, and summary outputs used in Appendices A, B, and C

These analyses were supplemental assessments of the already locked final model. They did not result in predictor removal, model refitting, additional tuning, or any change to the selected Linear Regression Group 3 specification.

Selected Week 7 appendix-analysis outputs are retained in:

[`appendix_analysis/`](appendix_analysis/)

The canonical analytical scripts remain in the repository `scripts/` directory so that the evidence folder contains a curated record of Week 7 results without duplicating the primary reproducibility workflow.

### Major Appendix Results

The county-clustered bootstrap analysis used 2,000 resamples.

Development-stage predictive performance:

- RMSE: 22.56, 95% bootstrap CI 21.21–23.75
- MAE: 18.10, 95% bootstrap CI 16.99–19.10
- R²: 0.553, 95% bootstrap CI 0.490–0.611

Final-holdout predictive performance:

- RMSE: 11.97, 95% bootstrap CI 11.18–12.77
- MAE: 9.79, 95% bootstrap CI 9.09–10.51
- R²: 0.392, 95% bootstrap CI 0.242–0.488

The final-model diagnostic review identified observations warranting closer inspection but did not identify a reason to alter the locked specification.

Conventional 95% prediction intervals covered 244 of 247 final-holdout observations, corresponding to 98.8% empirical coverage, with a mean interval width of approximately 56.85 bushels per acre.

These results were incorporated into the final thesis appendices and discussion of model uncertainty and limitations.

## Final Thesis Revision and Quality Control

Advisor feedback from the first thesis draft was reviewed and tracked using the project’s Advisor Feedback Action Plan.

The action plan is maintained at:

[`docs/project_management/Advisor_Feedback_Action_Plan.md`](../../docs/project_management/Advisor_Feedback_Action_Plan.md)

The final thesis manuscript was revised to address the advisor-feedback items and subsequent quality-control findings. Major revision areas included:

- predictive versus causal wording
- data-source and software documentation
- development-versus-holdout separation
- uncertainty and diagnostic analyses
- coefficient confidence intervals
- prediction intervals
- discussion of model limitations and dependence
- table and figure formatting
- heading, table-of-contents, and appendix organization
- final reference and citation review

After the manuscript revisions were completed, the final Word document underwent a full visual and structural review. The resulting PDF was then reviewed separately to confirm that conversion did not introduce formatting or pagination problems.

The final PDF retained the intended 55-page structure, table of contents, figures, tables, references, appendices, and supplementary-material links.

No additional model fitting, predictor selection, tuning, or post-holdout model changes were performed during the revision process.

## Final Figure Standardization

Final presentation-quality versions of the primary thesis figures were produced through the final figure-standardization workflow.

The Week 7 evidence folder contains copies of the standardized outputs in:

[`final_figure_standardization/`](final_figure_standardization/)

The standardized figures include:

- Linear Regression validation-year RMSE
- Random Forest validation-year RMSE
- XGBoost validation-year RMSE
- model-family comparison
- county-level Group 3 RMSE
- county-level change in RMSE from Group 1 to Group 3

The associated figure-refresh manifest is also retained to document the standardized output set.

These updates improved consistency in labeling, legends, grayscale readability, map presentation, and overall visual formatting without changing the underlying analytical results.

## Narrated Presentation Planning

Week 7 also established the initial structure for the final narrated thesis presentation.

The presentation is required to include narration on every slide and have a total duration between 40 and 60 minutes. The planned presentation currently contains 34 slides and is designed to function as an asynchronous thesis defense rather than a slide-by-slide reproduction of the written manuscript.

The canonical presentation-planning documents are maintained under:

[`docs/presentation/`](../../docs/presentation/)

### Presentation Storyline and Slide Outline

The initial presentation storyline follows the sequence:

**Problem → Why weather may add value → How the question was tested fairly → Which model performed best → Whether it generalized → Where it struggled → What the results mean**

The outline identifies the purpose, planned visual, and approximate narration time for each slide.

Canonical file:

- [`Final_Narrated_Presentation_Storyline_and_Outline.md`](../../docs/presentation/Final_Narrated_Presentation_Storyline_and_Outline.md)

### Figure and Result Selection

A separate planning document identifies:

- thesis figures that can be reused with minor adaptation
- figures that should be simplified for presentation viewing
- presentation-specific graphics that need to be created
- numerical results that should receive primary presentation emphasis
- detailed analytical outputs that should remain in the thesis or backup materials

Canonical file:

- [`Presentation_Figure_and_Result_Selection.md`](../../docs/presentation/Presentation_Figure_and_Result_Selection.md)

### Presentation Rubric Crosswalk

The presentation outline was reviewed against the final Assignment 5 rubric before slide development began.

The review confirmed coverage of:

- Introduction
- Background
- Hypothesis
- Methodology
- Literature Review
- Descriptive Statistics
- Inferential Statistics
- Discussion of Implications
- Delivery requirements
- Conclusion and Future Research

The review also resulted in targeted refinements to the planned presentation. The outline was strengthened to:

- explicitly explain the motivation for choosing the research topic
- make the descriptive-statistics requirement clearly visible
- clarify how inferential statistics and uncertainty will be presented
- reconnect the final findings with secondary literature during the Discussion

Canonical file:

- [`Presentation_Rubric_Crosswalk.md`](../../docs/presentation/Presentation_Rubric_Crosswalk.md)

## Week 7 Outcome

Week 7 completed the major final-thesis revision and supplemental diagnostic work while also establishing the foundation for development of the final narrated presentation.

Major outcomes included:

- completion of the final appendix and diagnostic analysis scripts
- completion of bootstrap uncertainty, coefficient-interval, influence, residual, and prediction-interval analyses
- preparation of final Appendix A, B, and C analytical outputs
- completion of the advisor-feedback revision process
- completion of final thesis manuscript quality control
- successful final PDF conversion and PDF-specific review
- completion of the final thesis figure-standardization work
- creation of the initial 34-slide narrated-presentation storyline and outline
- selection of thesis figures and numerical results for presentation
- identification of presentation-specific graphics to be created
- review of the presentation plan against the final grading rubric
- refinement of the presentation outline to address all identified rubric requirements

The final thesis analysis remains unchanged. Linear Regression with Group 3 predictors remains the formally selected model, and the 2022–2025 holdout remains the final evaluation period.

## Next Steps for Week 8

The next phase of the project will focus on developing the actual presentation slides from the completed Week 7 plan.

Planned upcoming work includes:

- beginning slide production for the Introduction, Background, Research Question, Literature Review, and Methods sections
- developing the first presentation-specific diagrams and graphics
- beginning the End-of-Semester Final Assignment
- continuing final supplementary-material preparation as needed
- completing Weekly Status Report #8
