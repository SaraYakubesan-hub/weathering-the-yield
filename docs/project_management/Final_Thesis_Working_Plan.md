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

The required supplementary-material package submitted with the first thesis draft will serve as the starting point for the final supplementary submission.

The final package will be updated only as needed to reflect revisions made between the first and final thesis drafts.

The required final folder and ZIP naming convention is:

`Final_Thesis_Submission_SaraYakubesan/`

and

`Final_Thesis_Submission_SaraYakubesan.zip`

The required top-level folders are:

- Code
- Graphs
- Illustrations
- Graphics
- Documentation

### Code

- [ ] Retain all preliminary proof-of-concept Scripts 01–05.
- [ ] Retain finalized thesis workflow Scripts 07–24.
- [ ] Include any additional scripts created during final revision only if they become part of the documented thesis workflow.
- [ ] Confirm that all submitted scripts contain descriptive comments and consistent formatting.
- [ ] Confirm that required package dependencies are documented in `Code/README.txt`.
- [ ] Update `Code/README.txt` if any final scripts, packages, output locations, or execution instructions change.
- [ ] Confirm that the distinction between preliminary Scripts 01–05 and the finalized workflow beginning with Script 07 remains clearly documented.

### Graphs

- [ ] Replace first-draft figure files with revised final versions where applicable.
- [ ] Confirm that all figures used in the final thesis are included.
- [ ] Confirm that filenames clearly correspond to the final manuscript figure numbering.
- [ ] Update `Graphs/README.txt` if figure wording, numbering, interpretation, or significance changes.
- [ ] Confirm that all figures open correctly and retain sufficient resolution for review.
- [ ] Confirm that figure captions and descriptions are consistent with the final thesis.

### Illustrations

- [ ] Retain `Illustrations/README.txt` if no separate illustrations or diagrams are used.
- [ ] Add any final thesis illustrations or diagrams if new materials are created.
- [ ] Update the README if the contents of this folder change.

### Graphics

- [ ] Retain `Graphics/README.txt` if no separate graphics or images are used.
- [ ] Add any final graphics if new materials are incorporated into the thesis or presentation of the research.
- [ ] Update the README if the contents of this folder change.

### Documentation

- [ ] Include the final Methodology Decision Table.
- [ ] Include the current project README.
- [ ] Update the supplementary-material index to reflect the final package.
- [ ] Retain the USDA source file used by the analysis.
- [ ] Retain the final processed development and holdout datasets.
- [ ] Retain the key model-comparison, model-lock, holdout, difficult-year, and spatial-diagnostic outputs.
- [ ] Update documentation if any analytical correction or final-draft change affects the supporting outputs.
- [ ] Confirm that documentation no longer contains outdated citations, dates, filenames, or descriptions.

### Final Package Quality-Control Audit

Before submission:

- [ ] Confirm that the main folder is named exactly `Final_Thesis_Submission_SaraYakubesan`.
- [ ] Confirm that the ZIP file is named exactly `Final_Thesis_Submission_SaraYakubesan.zip`.
- [ ] Confirm that all five required top-level subfolders are present.
- [ ] Confirm that no required files are missing.
- [ ] Confirm that no temporary, duplicate, or obsolete files are included.
- [ ] Verify that all R scripts open correctly.
- [ ] Verify that all CSV files are readable.
- [ ] Verify that the Methodology Decision Table opens correctly.
- [ ] Verify that all graphs and visual files open correctly.
- [ ] Verify README and index filenames and file extensions.
- [ ] Confirm that the Code README provides sufficient instructions to reproduce the workflow from the supplementary package.
- [ ] Confirm that figure descriptions accurately match the final figures.
- [ ] Open the completed ZIP and verify its contents before upload.

### Relationship to the First-Draft Package

The first-draft supplementary submission will remain unchanged as a record of the first-draft milestone.

A separate copy will be created for the final submission so that final revisions do not overwrite the previously submitted version.

Only changes supported by final thesis revisions, advisor feedback, analytical corrections, or final quality-control improvements will be incorporated into the final package.

---

## Narrated Presentation Plan

The Final Thesis Narrated Presentation will serve as the asynchronous equivalent of an oral thesis defense. The presentation will communicate the complete thesis project to an audience that may not already be familiar with the research topic or analytical methods.

The presentation is due December 10, 2026 at 5:00 PM and must include narration for every slide. The total narrated presentation must be between 40 and 60 minutes.

Presentation development will begin before the final thesis submission so that the major structure, figures, and explanations can be developed in parallel with final manuscript revisions. Final narration will be recorded after the thesis results and presentation content have been confirmed.

### Presentation Goals

The presentation should:

- [ ] Clearly explain the research problem and motivation.
- [ ] Be understandable to an audience without specialized knowledge of agricultural modeling or data science.
- [ ] Explain technical methods in accessible language without oversimplifying the research.
- [ ] Present the research question and hypothesis clearly.
- [ ] Explain why the selected datasets and variables are appropriate for the research question.
- [ ] Summarize the most relevant findings from the literature review.
- [ ] Explain the time-aware model-development and validation strategy.
- [ ] Present both descriptive and inferential/statistical information required by the presentation rubric.
- [ ] Clearly communicate the primary model-comparison and final holdout results.
- [ ] Discuss the practical and methodological implications of the findings.
- [ ] Distinguish predictive associations from causal conclusions.
- [ ] End with clear conclusions, limitations, and future research directions.

### Planned Presentation Content

The presentation will include the following major content areas.

#### Introduction and Research Motivation

- [ ] Introduce the presenter and thesis project.
- [ ] Explain the importance of corn production and yield prediction in Indiana.
- [ ] Describe the motivation for examining weather information in addition to historical yield patterns.
- [ ] Present the research problem in accessible language.
- [ ] Explain the reason for selecting this research topic.

#### Background

- [ ] Provide context on county-level corn-yield variation.
- [ ] Explain why historical yield information is useful for prediction.
- [ ] Introduce the potential role of growing-season temperature and precipitation.
- [ ] Explain why weather timing may matter.
- [ ] Explain the motivation for evaluating extreme-weather indicators separately from conventional weather summaries.

#### Research Question and Hypothesis

- [ ] Clearly state the primary research question.
- [ ] Clearly state the research hypothesis.
- [ ] Introduce the three nested predictor groups used to test the research question.

#### Literature Review

- [ ] Summarize the most important findings from the recent literature.
- [ ] Explain how the literature informed weather-window selection.
- [ ] Summarize evidence related to heat, drought, excessive moisture, and corn-yield prediction.
- [ ] Explain how previous research informed the use of historical yield information and time-aware validation.
- [ ] Focus on literature directly connected to the final methodology rather than attempting to summarize every reviewed article.

#### Data and Methodology

- [ ] Introduce USDA NASS Quick Stats corn-yield data.
- [ ] Introduce NOAA nClimGrid Daily weather data accessed through EpiNOAA.
- [ ] Describe the Indiana county-level study area and 2000–2025 study period.
- [ ] Explain the naturally unbalanced USDA county-year panel.
- [ ] Describe the historical baseline predictors.
- [ ] Explain the conventional weather features.
- [ ] Explain the retained extreme-weather indicators.
- [ ] Explain the multicollinearity assessment and exclusion of the hot-day-count variable.
- [ ] Introduce Linear Regression, Random Forest, and XGBoost in audience-friendly terms.
- [ ] Explain why time-aware validation was used instead of random train/test splitting.
- [ ] Explain the 2012–2021 expanding-window development-validation period.
- [ ] Explain why 2022–2025 was reserved for final evaluation.
- [ ] Describe the formal model-lock step before holdout evaluation.

### Descriptive Statistics

Because descriptive statistics are specifically evaluated in the presentation rubric, the presentation will include a concise description of the final analytical sample and relevant observed patterns.

Planned descriptive information may include:

- [ ] Number of development observations and counties.
- [ ] Number of final holdout observations and counties.
- [ ] Study-year coverage.
- [ ] Summary of observed corn yields.
- [ ] Selected weather-feature summaries where they help explain the analysis.
- [ ] Relevant year-to-year or difficult-year patterns.
- [ ] At least one useful table or visualization that demonstrates descriptive characteristics of the data.

The presentation will explain the meaning of these statistics rather than displaying numerical output without interpretation.

### Inferential and Model-Based Statistical Evidence

The rubric also specifically evaluates inferential statistics. Because the thesis is primarily predictive rather than causal, this portion of the

---

## End-of-Semester Assignment Plan

## End-of-Semester Assignment Plan

The End-of-Semester Final Assignment is a required Data Science program exit assessment based on the thesis project. Although the assignment is listed as 0 points, completion is required before the final course grade can be submitted.

The current Canvas due date is December 17, 2026 at 5:00 PM.

The assignment requires responses to 16 Program Learning Outcome (PLO) tasks in a single Microsoft Word document. Many tasks also require evidence from a Kaggle notebook, including screenshots and brief written explanations.

To avoid duplicating work, one organized Kaggle notebook will be developed and used to support multiple PLO requirements.

### Overall Strategy

The final assignment will be completed using the finalized thesis dataset and analytical context.

The work will be divided into three components:

1. A reusable Kaggle notebook containing data loading, inspection, cleaning, descriptive analysis, modeling, and visualization.
2. A set of screenshots selected from the notebook to provide evidence for the applicable PLO tasks.
3. A single Microsoft Word document containing responses to all 16 questions, screenshots, explanations, APA citations where required, and the dataset link.

The goal is to demonstrate the Data Science Program Learning Outcomes using the completed thesis project without unnecessarily recreating the full thesis analysis.

### Dataset Selection

The final processed thesis modeling dataset will be used as the primary dataset for the Kaggle assignment.

Before beginning:

- [ ] Confirm which processed thesis dataset is most appropriate for the assignment.
- [ ] Prefer a dataset that contains the final analytical variables in a clear county-year format.
- [ ] Confirm that the selected dataset can be uploaded to Kaggle.
- [ ] Create a clear Kaggle dataset title and description.
- [ ] Preserve variable names where practical so that the notebook remains consistent with the thesis.
- [ ] Include a link to the Kaggle dataset in the final Word document.
- [ ] Confirm that no restricted, confidential, or personally identifiable information is included.

### Kaggle Notebook Structure

A single notebook will be organized into clearly labeled sections so that screenshots can be reused across multiple PLO responses.

Planned notebook sections:

#### 1. Setup and Data Loading

- [ ] Load required Python or R packages.
- [ ] Import the thesis dataset.
- [ ] Display the first several observations.
- [ ] Report the number of rows and columns.
- [ ] Display variable names.
- [ ] Inspect data types.

#### 2. Data Quality Assessment

- [ ] Check missing values by variable.
- [ ] Check duplicate observations where appropriate.
- [ ] Review the county-year structure.
- [ ] Verify study-year coverage.
- [ ] Identify any important limitations of the dataset.
- [ ] Explain the naturally unbalanced county-year panel where relevant.

#### 3. Data Cleaning and Transformation

- [ ] Demonstrate appropriate cleaning or transformation steps.
- [ ] Verify numeric and categorical variable types.
- [ ] Address missing predictor values if needed.
- [ ] Confirm that outcome values are not artificially imputed.
- [ ] Create or verify selected analytical variables.
- [ ] Document why each transformation is appropriate.

#### 4. Descriptive Statistics

- [ ] Calculate mean, median, standard deviation, minimum, and maximum for selected variables.
- [ ] Summarize corn yield.
- [ ] Summarize selected weather variables.
- [ ] Interpret the results rather than reporting values alone.

#### 5. Variable Evaluation

Select three variables that are directly relevant to the thesis research question.

Potential candidates include:

- corn_yield
- lag1_yield
- one conventional weather predictor or retained extreme-weather predictor

The final variables will be selected so that their connection to the research question can be clearly explained.

#### 6. Predictive Modeling

- [ ] Fit a simple predictive model using the thesis dataset.
- [ ] Use an appropriate regression approach consistent with the project.
- [ ] Clearly identify the outcome and predictor variables.
- [ ] Report model results.
- [ ] Calculate appropriate prediction or fit metrics where useful.
- [ ] Explain what the results mean in the context of the thesis.
- [ ] Avoid causal interpretation.

The Kaggle model does not need to reproduce the entire nested thesis workflow unless required. The purpose of this section is to demonstrate the program learning outcome using an appropriate predictive analysis.

#### 7. Visualizations

- [ ] Create at least one visualization of the outcome distribution or temporal pattern.
- [ ] Create at least one visualization showing a meaningful predictor-outcome relationship.
- [ ] Create an additional visualization if needed to demonstrate another useful analytical insight.
- [ ] Label titles, axes, units, and legends clearly.
- [ ] Explain why each visualization is effective.

#### 8. Pipeline Diagram

Develop a simple data-science pipeline showing the major stages used in the thesis project.

Planned stages:

USDA NASS yield data + NOAA weather data  
→ Data ingestion  
→ Cleaning and quality checks  
→ County FIPS integration  
→ Feature engineering  
→ Modeling dataset  
→ Model development and evaluation  
→ Results and visualizations

- [ ] Create a clear pipeline diagram.
- [ ] Explain each pipeline component in approximately one paragraph.
- [ ] Ensure the diagram reflects the actual thesis workflow.

---

## PLO Task Plan

### PLO 01.1 – Computational Aspect

**Requirement:** Load the thesis dataset into Kaggle, organize it into a DataFrame or equivalent structure, and inspect missing values and data types.

Planned evidence:

- [ ] Screenshot of dataset loading.
- [ ] Screenshot of dataset preview.
- [ ] Screenshot of dimensions and data types.
- [ ] Screenshot of missing-value assessment.
- [ ] Write 1–2 paragraphs explaining the process.

### PLO 01.2 – Data

**Requirement:** Evaluate whether the thesis dataset is comprehensive and organized and identify any issues.

Planned response:

- [ ] Describe the county-year structure.
- [ ] Discuss study-period coverage.
- [ ] Discuss the naturally unbalanced USDA yield panel.
- [ ] Explain the availability of weather data.
- [ ] Identify relevant limitations.
- [ ] Include supporting notebook screenshots.
- [ ] Write 1–2 paragraphs.

### PLO 02 – Data Infrastructure and Pipeline

**Requirement:** Design a simple data pipeline including ingestion and processing.

Planned response:

- [ ] Create a pipeline diagram.
- [ ] Show USDA and NOAA data as the primary inputs.
- [ ] Show cleaning, integration, feature engineering, modeling, and output stages.
- [ ] Explain each major component.
- [ ] Include the diagram and relevant notebook evidence.

### PLO 02.1 – Data Processing

**Requirement:** Perform and document data cleaning and transformation.

Planned evidence:

- [ ] Missing-value assessment.
- [ ] Data-type verification.
- [ ] Duplicate checks.
- [ ] Selected transformations.
- [ ] Explanation of how missing yield outcomes were handled.
- [ ] Screenshots of relevant notebook cells.
- [ ] Brief written explanation.

### PLO 03.1 – Evaluate Information and Its Sources Critically

**Requirement:** Select three dataset columns and evaluate their relevance to the research question.

Planned response:

- [ ] Select three meaningful variables.
- [ ] Explain what each variable represents.
- [ ] Explain why each is relevant to predicting county-level corn yield.
- [ ] Identify any limitations in how each variable should be interpreted.
- [ ] Include relevant notebook evidence.
- [ ] Write 1–2 paragraphs.

### PLO 03.2 – Use Information Effectively to Accomplish a Specific Purpose

**Requirement:** Use the variables selected for PLO 03.1 to explain how they contribute to the research question.

Planned response:

- [ ] Connect the selected variables directly to the thesis research question.
- [ ] Explain how historical and weather information contribute different types of predictive information.
- [ ] Synthesize the variables rather than discussing them independently.
- [ ] Write 1–2 paragraphs.

### PLO 03.3 – Existing Knowledge, Research, and/or Views

**Requirement:** Summarize the thesis topic using at least three academic sources.

Planned response:

- [ ] Select at least three recent peer-reviewed sources already used in the thesis.
- [ ] Summarize findings related to corn yield, growing-season weather, and/or extreme weather.
- [ ] Synthesize the sources rather than presenting three disconnected summaries.
- [ ] Use APA in-text citations.
- [ ] Include complete references in the final document.
- [ ] Write 1–2 paragraphs.

### PLO 03.4 – Interpretation / Quantitative Literacy

**Requirement:** Interpret the thesis dataset using basic statistical techniques.

Planned evidence:

- [ ] Mean.
- [ ] Median.
- [ ] Standard deviation.
- [ ] Minimum and maximum where helpful.
- [ ] Interpret statistics for corn yield and selected predictors.
- [ ] Include notebook screenshots.
- [ ] Write 1–2 paragraphs explaining what the statistics reveal.

### PLO 04 – Quantitative Techniques and Predictive Modeling

**Requirement:** Develop a simple predictive model using an appropriate quantitative technique.

Planned response:

- [ ] Fit an appropriate regression model.
- [ ] Identify outcome and predictors.
- [ ] Report model results.
- [ ] Evaluate model performance using appropriate metrics where practical.
- [ ] Explain how the model relates to the thesis research question.
- [ ] Include notebook screenshots.
- [ ] Write 1–2 paragraphs.

### PLO 05 – Programming for Data Analysis

**Requirement:** Write a Python or R program containing data cleaning, exploratory analysis, and model fitting.

The organized Kaggle notebook will serve as the primary program for this requirement.

Planned evidence:

- [ ] Data import code.
- [ ] Data-cleaning code.
- [ ] Exploratory-analysis code.
- [ ] Model-fitting code.
- [ ] Relevant output.
- [ ] Screenshots showing the complete analytical workflow.
- [ ] Write 1–2 paragraphs summarizing the program and results.

### PLO 06 – Data Visualization

**Requirement:** Create and evaluate visualizations that reveal analytical insights.

Planned response:

- [ ] Select clear visualizations produced in the Kaggle notebook.
- [ ] Explain what each visualization shows.
- [ ] Explain why the selected visual form is appropriate for the information.
- [ ] Identify meaningful insights revealed by the visualizations.
- [ ] Include screenshots.
- [ ] Write 1–2 paragraphs evaluating their effectiveness.

### PLO 07 – Social, Legal, and Ethical Issues

**Requirement:** Evaluate social, legal, and ethical issues associated with the thesis dataset.

Potential discussion areas:

- [ ] Responsible interpretation of predictive agricultural models.
- [ ] Risks of overstating predictive associations as causal relationships.
- [ ] Unequal representation caused by missing county-year yield observations.
- [ ] Consequences of using models outside the geographic or temporal setting in which they were evaluated.
- [ ] Responsible use and attribution of public government datasets.
- [ ] Write 1–2 paragraphs.

### PLO 07.1 – Different Ethical Perspectives and Concepts

**Requirement:** Discuss ethical implications from multiple perspectives, including objections, assumptions, and consequences.

Potential perspectives may include:

- [ ] Researchers seeking accurate and reproducible results.
- [ ] Farmers or agricultural decision-makers who may rely on predictive information.
- [ ] Public agencies responsible for collecting and distributing agricultural or environmental data.
- [ ] Communities potentially affected by inaccurate or overgeneralized conclusions.
- [ ] Assumptions and limitations underlying predictive modeling.
- [ ] Write 1–2 paragraphs.

### PLO 07.2 – Privacy and Identifiers

**Requirement:** Develop a strategy for handling privacy issues related to personal identifiers.

The thesis dataset contains county-level agricultural and weather information rather than individual-level personal information.

Planned response:

- [ ] Explicitly state that the thesis dataset does not contain personal identifiers.
- [ ] Explain why county FIPS codes are geographic identifiers rather than personal identifiers.
- [ ] Describe how personally identifiable information would be removed, minimized, protected, or access-controlled if it were present in another dataset.
- [ ] Discuss the principle of collecting and retaining only information necessary for the research purpose.
- [ ] Write 1–2 paragraphs.

### PLO 07.3 – Ethical Considerations Across Cultural and Societal Contexts

**Requirement:** Evaluate ethical implications while considering diverse cultural and societal contexts.

Potential discussion areas:

- [ ] Differences in resources available to agricultural producers.
- [ ] Risks of assuming that a model developed for Indiana applies to other regions or farming systems.
- [ ] Differences in climate, production practices, infrastructure, and access to technology.
- [ ] The importance of communicating uncertainty and limitations when analytical results may inform decisions.
- [ ] Write 1–2 paragraphs.

### PLO 07.4 – Ethical and Legal Use of Information

**Requirement:** Discuss ethical use of data in research using APA citations and references.

Planned response:

- [ ] Discuss appropriate attribution of data sources.
- [ ] Discuss transparent documentation of analytical methods.
- [ ] Discuss reproducibility and responsible reporting.
- [ ] Discuss compliance with data-access and usage requirements.
- [ ] Use appropriate academic or authoritative sources.
- [ ] Include APA citations and references.
- [ ] Write 1–2 paragraphs.

---

## Screenshot Strategy

Screenshots will be selected intentionally rather than capturing every notebook cell.

Each screenshot should:

- [ ] Show the relevant code and/or output clearly.
- [ ] Be large enough to read in the final Word document.
- [ ] Exclude unrelated notebook content where possible.
- [ ] Include enough context to demonstrate what task was performed.
- [ ] Use consistent screenshot sizing in the final document.
- [ ] Be referenced in the accompanying written explanation.

The same screenshot may be reused for more than one PLO when it legitimately demonstrates multiple requirements.

### Final Word Document

All 16 responses will be assembled into one Microsoft Word document.

Planned organization:

1. Title
2. Kaggle dataset and notebook information
3. PLO 01.1
4. PLO 01.2
5. PLO 02
6. PLO 02.1
7. PLO 03.1
8. PLO 03.2
9. PLO 03.3
10. PLO 03.4
11. PLO 04
12. PLO 05
13. PLO 06
14. PLO 07
15. PLO 07.1
16. PLO 07.2
17. PLO 07.3
18. PLO 07.4
19. References

Each PLO section will clearly identify:

- the task being addressed,
- the evidence or screenshot,
- the required brief written explanation,
- and any relevant interpretation.

### Final Quality-Control Review

Before submission:

- [ ] Confirm that all 16 PLO questions are answered.
- [ ] Confirm that all required Kaggle screenshots are included.
- [ ] Confirm that the Kaggle dataset link is included.
- [ ] Confirm that all screenshots are readable.
- [ ] Confirm that required 1–2 paragraph responses are complete.
- [ ] Verify all numerical values against the Kaggle notebook output.
- [ ] Confirm that the predictive analysis is described accurately and without unsupported causal language.
- [ ] Verify APA citations and references for PLO 03.3 and PLO 07.4.
- [ ] Confirm that every source cited in the assignment appears in the reference list.
- [ ] Review spelling, grammar, headings, and document formatting.
- [ ] Confirm that all 16 sections appear in the correct order.
- [ ] Open the completed Word file after saving to verify that screenshots and formatting display correctly.
- [ ] Verify the current Canvas deadline immediately before submission.
- [ ] Confirm successful upload before considering the assignment complete.

### Development Sequence

The End-of-Semester Assignment will be developed in stages:

1. Confirm the thesis dataset to use in Kaggle.
2. Upload and document the dataset.
3. Create the structured Kaggle notebook.
4. Complete the shared computational sections that support multiple PLOs.
5. Capture and organize screenshots.
6. Draft PLO 01–06 responses using notebook evidence.
7. Draft the PLO 07-series ethical and legal responses.
8. Complete the literature-based PLO responses and APA references.
9. Assemble all responses into the required Microsoft Word document.
10. Perform a question-by-question requirement audit.
11. Verify the final Kaggle links and evidence.
12. Submit the completed assignment by the current December 17, 2026 deadline.

---

## Weekly Work Plan

The remaining semester work will be organized around Weekly Status Reports 6–10. Each week will document completed work, supporting GitHub evidence where appropriate, and progress toward the final thesis, narrated presentation, and End-of-Semester Final Assignment.

The weekly plan may be adjusted if advisor feedback requires a change in priority.

### Week 6

**Status Report #6 Due:** October 29, 2026

**Primary Focus:** Transition from first-draft completion into final revision and course-completion planning.

Planned work:

- [x] Complete and submit the first thesis draft.
- [x] Complete and submit the required first-draft supplementary-material package.
- [x] Perform a final pre-submission audit of the supplementary package.
- [x] Review remaining INFO-I 492 course requirements.
- [x] Document deadlines for the final thesis, final supplementary materials, narrated presentation, and End-of-Semester Final Assignment.
- [x] Create the Final Thesis Working Plan.
- [ ] Complete the Week 6 GitHub evidence documentation.
- [ ] Complete and submit Weekly Status Report #6.

**Expected Week 6 Evidence:**

- First thesis draft submission milestone
- First-draft supplementary-material submission milestone
- `Final_Thesis_Working_Plan.md`
- Week 6 evidence README
- Updated repository documentation as appropriate

**Week 6 Outcome:**

Establish a documented transition from the completed primary analysis and first-draft submission into the final revision, communication, and course-completion phase.

---

### Week 7

**Status Report #7 Due:** November 5, 2026

**Primary Focus:** Begin final thesis revision work and establish the narrated presentation structure.

Planned work:

- [ ] Review any first-draft feedback received from Dr. R.
- [ ] Categorize advisor feedback by thesis section and priority.
- [ ] Begin required manuscript revisions if feedback is available.
- [ ] Begin the final thesis figure-improvement work that was intentionally deferred from the first draft.
- [ ] Create the initial narrated-presentation storyline and slide outline.
- [ ] Identify which thesis figures and results should appear in the presentation.
- [ ] Review the presentation rubric while developing the outline.
- [ ] Prepare Week 7 GitHub evidence.
- [ ] Complete and submit Weekly Status Report #7.

If advisor feedback has not yet been received, work will focus on presentation planning, deferred figure improvements, and other final-draft quality-control tasks that do not depend on advisor comments.

**Expected Week 7 Evidence:**

- Advisor-feedback action plan, if feedback has been received
- Initial presentation outline or planning documentation
- Revised thesis figures where completed
- Week 7 evidence README

**Week 7 Outcome:**

Begin the active final-revision phase while also establishing the structure for the final narrated presentation.

---

### Week 8

**Status Report #8 Due:** November 12, 2026

**Primary Focus:** Continue thesis revisions, advance presentation development, and begin the End-of-Semester Final Assignment.

Planned work:

- [ ] Continue revisions based on Dr. R’s first-draft feedback.
- [ ] Continue or complete planned figure improvements.
- [ ] Verify that revised thesis text remains consistent with final analytical outputs.
- [ ] Begin developing presentation slides for the Introduction, Background, Research Question, Literature Review, and Methods.
- [ ] Confirm the thesis dataset to use for the End-of-Semester Kaggle assignment.
- [ ] Set up the Kaggle dataset and notebook.
- [ ] Begin the shared computational notebook sections for data loading, structure, missingness, and data-quality evaluation.
- [ ] Prepare Week 8 GitHub evidence.
- [ ] Complete and submit Weekly Status Report #8.

**Expected Week 8 Evidence:**

- Thesis revision progress
- Updated figures or manuscript-supporting materials
- Narrated-presentation development progress
- Kaggle assignment setup or notebook progress
- Week 8 evidence README

**Week 8 Outcome:**

Maintain progress on the final thesis while beginning the two major post-thesis deliverables early enough to avoid concentrating all remaining work in December.

---

### Week 9

**Status Report #9 Due:** November 19, 2026

**Primary Focus:** Move the final thesis toward completion while substantially advancing the presentation and exit-assessment work.

Planned work:

- [ ] Complete the majority of advisor-directed thesis revisions.
- [ ] Complete planned figure revisions unless additional advisor feedback requires further changes.
- [ ] Begin the final manuscript quality-control audit.
- [ ] Continue developing presentation slides for Results, Difficult-Year Diagnostics, Final Holdout Evaluation, Spatial Diagnostics, Discussion, and Conclusion.
- [ ] Identify descriptive statistics to include in the presentation.
- [ ] Determine the appropriate inferential/model-based statistical evidence for the presentation.
- [ ] Continue the Kaggle notebook through data processing, descriptive statistics, modeling, and visualization.
- [ ] Begin drafting End-of-Semester PLO responses that can be supported by completed notebook sections.
- [ ] Prepare Week 9 GitHub evidence.
- [ ] Complete and submit Weekly Status Report #9.

**Expected Week 9 Evidence:**

- Substantial final-thesis revision progress
- Updated final figures
- Presentation slide-development progress
- Kaggle notebook progress
- Initial PLO response work
- Week 9 evidence README

**Week 9 Outcome:**

Reach a point where the final thesis is largely complete and both remaining December deliverables have substantial work already finished.

---

### Thanksgiving Week

**November 26, 2026**

No weekly status report is scheduled.

This period can be used flexibly for continued thesis polishing, presentation development, or End-of-Semester Assignment work as needed.

No major project milestone will depend on work being completed during the Thanksgiving break.

---

### Week 10

**Status Report #10 Due:** December 3, 2026

**Final Thesis Paper Due:** December 3, 2026 at 5:00 PM

**Required Final Supplementary Materials Due:** December 3, 2026 at 5:00 PM

**Primary Focus:** Complete, verify, and submit the final thesis and final supplementary-material package.

Planned work:

- [ ] Complete all remaining advisor-directed revisions.
- [ ] Perform the final thesis content audit.
- [ ] Verify all numerical results against final analytical outputs.
- [ ] Complete the APA citation and reference audit.
- [ ] Complete the final formatting and template audit.
- [ ] Update the Table of Contents.
- [ ] Verify final figure numbering, captions, and in-text references.
- [ ] Create the final supplementary-material package from the first-draft package baseline.
- [ ] Replace first-draft figures with final versions where applicable.
- [ ] Update final README and documentation files as necessary.
- [ ] Perform the final supplementary-package rubric audit.
- [ ] Verify the final ZIP contents and naming convention.
- [ ] Submit the Final Thesis Paper.
- [ ] Submit the required final supplementary-material package.
- [ ] Prepare Week 10 GitHub evidence.
- [ ] Complete and submit Weekly Status Report #10.

**Expected Week 10 Evidence:**

- Final thesis completion milestone
- Final supplementary-material completion milestone
- Final figure revisions
- Updated reproducibility documentation
- Week 10 evidence README

**Week 10 Outcome:**

Complete the thesis-writing and reproducibility phase of INFO-I 492 and transition fully to completion of the narrated presentation and End-of-Semester Final Assignment.

---

## Post-Week-10 Work

Although Weekly Status Report #10 is the final weekly report, two major course deliverables remain after December 3.

### December 4–10: Final Narrated Presentation

- [ ] Complete all presentation slides.
- [ ] Verify that presentation results match the submitted final thesis.
- [ ] Complete speaker notes.
- [ ] Practice the presentation.
- [ ] Confirm the presentation falls within the required 40–60 minute duration.
- [ ] Revise explanations for clarity and accessibility.
- [ ] Record narration for every slide.
- [ ] Perform a complete playback and quality-control review.
- [ ] Submit the narrated presentation by December 10, 2026 at 5:00 PM.

### December 11–17: End-of-Semester Final Assignment

- [ ] Complete any remaining Kaggle notebook sections.
- [ ] Capture final screenshots.
- [ ] Complete all 16 PLO responses.
- [ ] Complete APA citations and references where required.
- [ ] Assemble the responses, screenshots, and supporting material into one Microsoft Word document.
- [ ] Audit the document against all 16 assignment requirements.
- [ ] Verify Kaggle dataset and notebook links.
- [ ] Perform final document quality control.
- [ ] Submit the End-of-Semester Final Assignment by the current Canvas deadline of December 17, 2026 at 5:00 PM.

---

## Weekly Planning Principle

Each weekly status report will describe work that was actually completed during that reporting period. The activities listed above represent the current plan and may be reordered when necessary in response to advisor feedback, assignment needs, or progress made earlier than expected.

The working plan will be updated as tasks are completed so that the repository provides a continuing record of project progress through the end of the semester.

---

## Deferred Improvements

The following items are considered lower-priority improvements that may be completed during final revision if time permits or if they become relevant through advisor feedback.

These items should not take priority over required revisions, final-submission requirements, or major course deliverables.

### Figure and Visual Refinement

- [ ] Review overall visual consistency across all thesis figures after the required final-draft figure updates are complete.
- [ ] Standardize font sizing, legend placement, and spacing where practical.
- [ ] Confirm that all figures remain readable when inserted at final manuscript size.
- [ ] Consider whether any presentation-specific versions of thesis figures would improve readability for the narrated presentation.
- [ ] Avoid unnecessary visual redesign if the existing figure communicates the result clearly.

### Manuscript Presentation

- [ ] Review paragraph length and section transitions for readability.
- [ ] Improve wording where technical explanations can be made more accessible without reducing accuracy.
- [ ] Review repeated terminology and remove unnecessary repetition where appropriate.
- [ ] Confirm that major analytical choices are explained consistently across Methods, Results, and Discussion.

### Repository Documentation

- [ ] Review the main project README after the final thesis is complete.
- [ ] Update repository documentation if final-draft revisions change figure descriptions, terminology, or analytical interpretation.
- [ ] Confirm that the scripts README remains consistent with the finalized analysis workflow.
- [ ] Add final course-completion documentation only where it contributes useful reproducibility or project-management context.

### Presentation Enhancements

- [ ] Consider adding simple explanatory diagrams for technical concepts such as expanding-window validation or the three predictor groups.
- [ ] Consider creating presentation-specific summary graphics when existing thesis figures are too detailed for narrated slides.
- [ ] Use examples or simplified visuals to explain model evaluation metrics if needed for a nontechnical audience.
- [ ] Keep additional presentation graphics focused on explanation rather than decoration.

### End-of-Semester Assignment Enhancements

- [ ] Improve the Kaggle notebook organization and explanatory markdown beyond the minimum assignment requirements if time permits.
- [ ] Add clear section headings and interpretation directly within the notebook.
- [ ] Preserve the notebook as a concise demonstration of the completed data-science workflow rather than attempting to duplicate every thesis analysis step.

### Priority Principle

Deferred improvements will be completed only after:

1. required advisor feedback has been addressed,
2. the final thesis requirements are satisfied,
3. the final supplementary-material package is complete,
4. presentation requirements are on schedule,
5. and the End-of-Semester Final Assignment is on track.

The purpose of this section is to preserve useful improvement ideas without allowing optional polishing to interfere with required course deliverables.

---

## Progress Log

*To be updated as major milestones are completed.*
