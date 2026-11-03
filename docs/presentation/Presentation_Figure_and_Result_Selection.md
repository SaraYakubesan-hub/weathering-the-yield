# Presentation Figure and Result Selection

**Project:** Weathering the Yield: Predicting Indiana Corn Yield with Growing-Season Weather Extremes  
**Course:** INFO-I 492 Senior Thesis  
**Prepared:** November 2, 2026  
**Presentation Due:** December 10, 2026  
**Status:** Week 7 figure and result selection plan

---

## Purpose

This document identifies the thesis figures, tables, numerical results, and presentation-specific graphics that will be used in the final narrated senior-thesis presentation.

The goal is not to reproduce every table and figure from the written thesis. Instead, the presentation will prioritize visuals that directly support the research question, explain important methodological decisions, demonstrate model performance, and help a nontechnical audience understand the major findings.

Existing thesis figures will be reused only when they remain clear at normal presentation size. Other results will be simplified, adapted, or redesigned specifically for narrated-slide viewing.

---

## Selection Categories

### Reuse with Minor Adaptation

These thesis figures already communicate an important result effectively. They may require larger labels, simplified captions, or presentation-specific cropping, but the underlying visual will remain substantially unchanged.

### Create Presentation-Specific Version

These results are important to the presentation but are better communicated through a simplified chart, diagram, timeline, or summary graphic rather than directly inserting a thesis table or appendix output.

### Omit from Main Presentation

These materials remain important to the thesis and reproducibility record but are too detailed, redundant, or technical for the main narrated presentation. Selected information may still be summarized verbally or used in backup slides if needed.

---

# Existing Thesis Figures Selected for the Presentation

## Figure 1 – Linear Regression RMSE by Validation Year and Predictor Group

**Presentation slide:** Slide 17 – *Linear Regression: Adding Weather Helped*  
**Decision:** Reuse with minor adaptation

### Why it should be included

Figure 1 directly illustrates the central predictor-group comparison within the model family that ultimately performed best. It shows that performance varied by year while also demonstrating the general advantage of Group 3.

The figure provides more information than a pooled metric alone because the audience can see that the result was not driven by a single validation year.

### Planned presentation adaptation

- Increase axis-title and legend font size if needed.
- Retain the standardized Group 1, Group 2, and Group 3 visual treatment developed for the final thesis.
- Consider reducing nonessential caption text.
- Add one concise callout emphasizing that Group 3 had the lowest Linear Regression RMSE in 7 of 10 validation years.
- Narration should emphasize the unusually difficult 2012 season without allowing that year to dominate interpretation.

### Key results to narrate

- Group 1 pooled RMSE: 36.14 bushels per acre
- Group 2 pooled RMSE: 35.35
- Group 3 pooled RMSE: 22.56
- Group 3 reduced pooled RMSE approximately 37.6% relative to Group 1.
- Group 3 remained the strongest Linear Regression specification when 2012 was excluded.

---

## Figure 4 – Model-Family RMSE Comparison

**Presentation slide:** Slide 19 – *All Nine Models Compared*  
**Decision:** Reuse or simplify depending on slide readability

### Why it should be included

Figure 4 provides the most complete visual comparison of the nine algorithm and predictor-group specifications evaluated during development.

It supports the important point that the final Linear Regression model was not selected merely because it was simpler or easier to interpret. It was selected after direct comparison with Random Forest and XGBoost under the same time-aware validation framework.

### Planned presentation adaptation

First test the final thesis version at full-slide size.

If all facets, labels, and line styles remain easily readable, reuse the standardized figure.

If it appears visually dense, create a simplified ranked comparison emphasizing pooled RMSE for the nine specifications while retaining the thesis figure as an optional backup slide.

### Key result to emphasize

**Linear Regression Group 3 ranked first overall on pooled RMSE, pooled MAE, and pooled out-of-sample R².**

The presentation should also note that Linear Regression Group 3 produced the strongest overall performance in 6 of the 10 development-validation years.

---

## Figure 5 – Observed and Predicted Corn Yield in the Final Holdout

**Presentation slide:** Slide 26 – *Observed vs. Predicted Yield*  
**Decision:** Reuse with minor adaptation

### Why it should be included

Figure 5 provides a visual explanation of final holdout performance that is easier to understand than RMSE alone.

It allows the audience to see that the locked model generally tracked the observed yield pattern while also showing the tendency for predictions to be compressed toward the center of the observed distribution.

### Planned presentation adaptation

- Enlarge plotting text if necessary.
- Maintain the holdout-year distinctions.
- Consider adding a short annotation explaining that perfect predictions would fall on the reference line.
- Avoid overcrowding the visual with additional statistical labels.

### Interpretation to narrate

The model generally tracked observed county-level yields but predicted a narrower range than was observed. Lower observed yields tended to be predicted somewhat higher, while very high observed yields tended to be predicted somewhat lower.

This compression toward the mean is an important limitation of the final model even though pooled holdout prediction error was relatively low.

---

## Figure 7 – County-Level RMSE for Linear Regression Group 3

**Presentation slide:** Slide 28 – *Where Did the Model Perform Better or Worse?*  
**Decision:** Reuse with minor adaptation

### Why it should be included

The spatial RMSE map demonstrates that statewide average performance does not imply uniform accuracy across Indiana.

It provides an intuitive transition from overall model performance to geographic variation in prediction difficulty.

### Planned presentation adaptation

- Retain the final standardized white background and county boundaries.
- Increase legend and title size if necessary for presentation viewing.
- Keep no-data counties clearly distinguished.
- Avoid adding county labels unless a specific county is discussed.

### Interpretation to narrate

County-level RMSE varied across the state, showing that some locations remained more difficult to predict even with the selected Group 3 model.

County-specific estimates should be interpreted cautiously because counties contributed different numbers of eligible validation observations.

---

## Figure 8 – County-Level Change in RMSE from Group 1 to Group 3

**Presentation slide:** Slide 29 – *Did Weather Help Across Indiana?*  
**Decision:** Reuse with minor adaptation

### Why it should be included

This is one of the strongest visual answers to the research question.

Rather than showing only where prediction error was high or low, Figure 8 directly shows where adding conventional and extreme-weather information improved prediction relative to the historical baseline.

### Planned presentation adaptation

- Retain the zero-centered diverging scale.
- Keep positive versus negative RMSE change visually obvious.
- Increase legend text if needed.
- Include a large numerical callout:

**78 of 89 evaluated counties showed lower RMSE with Group 3.**

### Key result to narrate

Adding weather information reduced county-level RMSE in approximately **87.6% of evaluated counties**.

Improvement was not spatially uniform, which reinforces that weather information contributed differently across locations.

---

# Thesis Figures Not Planned for the Main Presentation

## Figures 2 and 3 – Random Forest and XGBoost Validation-Year RMSE

**Decision:** Omit from the main presentation

### Rationale

These figures repeat the same predictor-group comparison shown in Figure 1 for different model families.

The presentation should explain the Random Forest and XGBoost results, but showing all three year-by-year figures would consume substantial time and visual space without adding proportionate explanatory value.

Their performance will instead be summarized on Slides 18 and 19.

These figures may be retained as backup slides if desired.

---

## Figure 6 – Holdout Residual Distributions

**Decision:** Omit from the main presentation

### Rationale

Figure 6 is useful diagnostically but is less intuitive for a general audience than Figure 5.

The important residual findings can be described briefly when discussing holdout performance and limitations.

The figure may be retained as a backup diagnostic slide.

---

## Appendix Figures C1–C5

**Decision:** Do not include directly in the main presentation

### Rationale

The appendix diagnostics support the validity and limitations of the selected model but are too detailed for the primary narrative.

Selected findings from these diagnostics should instead be summarized on the uncertainty and limitations slides.

One appendix visual may be adapted if it materially improves the explanation of prediction intervals or uncertainty, but the original appendix figures should not automatically be inserted into the presentation.

---

# Presentation-Specific Visuals to Create

## 1. Historical Information + Current-Season Weather → Yield Prediction

**Presentation slide:** Slide 3 – *The Prediction Problem*  
**Decision:** Create new

### Purpose

Provide a simple conceptual explanation of the thesis before technical terminology is introduced.

### Proposed structure

Historical county information  
**+**  
Current growing-season weather  
**→**  
Predicted county corn yield

Historical information could include:

- county identity,
- long-term yield trend,
- previous-year yield.

Weather could include:

- temperature,
- precipitation,
- extreme heat,
- dry spells,
- heavy rainfall.

---

## 2. Three Predictor-Group Diagram

**Presentation slides:** Slides 4, 6, and especially 10  
**Decision:** Create new

### Proposed structure

**Group 1 — Historical**

County identity  
Year trend  
Previous-year yield

↓

**Group 2 — Historical + Conventional Weather**

Group 1  
+ early-season temperature and precipitation  
+ reproductive-period temperature and precipitation  
+ grain-fill temperature and precipitation

↓

**Group 3 — Historical + Conventional Weather + Extremes**

Group 2  
+ accumulated heat above 35°C  
+ longest July–August dry spell  
+ maximum May–July 5-day precipitation

This should become one of the recurring visual anchors of the presentation.

---

## 3. Study-Period Timeline

**Presentation slide:** Slide 7 – *Study Design at a Glance*  
**Decision:** Create new

### Proposed structure

**2000** → weather/yield history begins

**2001–2021** → development dataset

**2012–2021** → expanding-window validation years

**MODEL LOCK**

**2022–2025** → untouched final holdout

This visual should make the development/holdout separation immediately understandable.

---

## 4. Data-Source Integration Diagram

**Presentation slide:** Slide 8 – *Data Sources*  
**Decision:** Create new

### Proposed structure

USDA NASS Quick Stats  
County corn yield

+

NOAA nClimGrid-Daily  
Daily temperature and precipitation

↓

FIPS + Year Integration

↓

County-Year Modeling Dataset

This should remain simple and should not reproduce the entire preprocessing workflow.

---

## 5. Analytical Sample Summary

**Presentation slide:** Slide 9 – *Analytical Sample*  
**Decision:** Create new

### Primary descriptive statistics

**Development**
- 2001–2021
- 1,691 county-year observations
- 91 Indiana counties

**Final holdout**
- 2022–2025
- 247 county-year observations
- 82 counties

### Additional note

The USDA yield data form a naturally unbalanced panel because corn yield was not reported for every county in every year.

This slide will satisfy part of the presentation requirement for descriptive statistics.

---

## 6. Growing-Season Weather-Window Timeline

**Presentation slide:** Slide 11 – *Weather Windows*  
**Decision:** Create new

### Proposed timeline

**May–June**
Early-season conditions

**July**
Reproductive-critical period

**August–September**
Grain-filling conditions

Show mean temperature and total precipitation associated with each period.

The visual should reinforce that weather timing, rather than only full-season averages, was central to feature engineering.

---

## 7. Extreme-Weather Feature Summary

**Presentation slide:** Slide 12 – *Extreme-Weather Features*  
**Decision:** Create new

Display three retained indicators:

- Accumulated July heat above 35°C
- Longest July–August dry spell
- Maximum May–July rolling 5-day precipitation

Include a smaller note explaining:

> July hot-day count above 30°C was evaluated but excluded after the multicollinearity assessment because it overlapped strongly with July mean temperature.

Avoid displaying VIF details unless needed in narration.

---

## 8. Model-Family Overview

**Presentation slide:** Slide 13 – *Three Modeling Approaches*  
**Decision:** Create new

### Proposed three-column structure

**Linear Regression**
- interpretable
- additive relationships
- strong benchmark

**Random Forest**
- nonlinear
- tree-based
- automatically captures interactions

**XGBoost**
- sequential boosted trees
- nonlinear
- flexible predictive model

The goal is conceptual understanding, not algorithm mathematics.

---

## 9. Random Split vs. Time-Aware Validation Diagram

**Presentation slide:** Slide 14 – *Why Random Splitting Would Be Misleading*  
**Decision:** Create new

### Left side

**Random split**

Past and future years mixed between training and testing.

Mark as inappropriate for a future-prediction question.

### Right side

**Time-aware split**

Only earlier years train a model used to predict a later year.

Mark as the approach used in this study.

---

## 10. Expanding-Window Validation Diagram

**Presentation slide:** Slide 15 – *Expanding-Window Validation*  
**Decision:** Create new

Illustrate several representative folds rather than all ten.

Example:

Train 2001–2011 → Predict 2012

Train 2001–2012 → Predict 2013

Train 2001–2013 → Predict 2014

…

Train 2001–2020 → Predict 2021

This visual is important enough to receive substantial narration.

---

## 11. Model Lock / Final Holdout Workflow

**Presentation slide:** Slide 16 – *Protecting the Final Test*  
**Decision:** Create new

### Proposed flow

Feature development  
→ model comparison  
→ sensitivity analysis  
→ difficult-year diagnostic  
→ **FINAL MODEL LOCKED**  
→ open 2022–2025 holdout  
→ final evaluation only

Add a small statement:

**No predictor, tuning, or model-family changes were made after viewing holdout results.**

---

## 12. Random Forest and XGBoost Summary

**Presentation slide:** Slide 18 – *What Happened with Random Forest and XGBoost?*  
**Decision:** Create new

Rather than using Figures 2 and 3, create a compact comparison.

### Suggested pooled Group 3 values

| Model | RMSE | MAE | R² |
|---|---:|---:|---:|
| Linear Regression | **22.56** | **18.10** | **0.553** |
| XGBoost | 28.44 | 22.20 | 0.289 |
| Random Forest | 29.41 | 23.00 | 0.240 |

Highlight Linear Regression Group 3.

This allows the audience to understand the result quickly without seeing three separate validation-year charts.

---

## 13. Model-Selection Summary

**Presentation slide:** Slide 20 – *Why Linear Regression Group 3 Was Selected*  
**Decision:** Create new

Use four concise pieces of evidence:

- Lowest pooled RMSE
- Lowest pooled MAE
- Highest pooled R²
- Best overall model in 6 of 10 validation years

Include:

**2012-exclusion sensitivity result: ranking remained unchanged**

This reinforces that model selection was based on multiple pieces of development-stage evidence.

---

## 14. Selected-Coefficient Forest Plot

**Presentation slide:** Slide 21 – *What the Final Linear Model Says*  
**Decision:** Create new from Appendix B results

### Purpose

Meet the presentation rubric requirement for inferential/model-based statistical evidence while keeping interpretation manageable.

### Recommended coefficient selection

Use approximately 5–6 non-county terms that best support interpretation.

Candidate terms should represent:

- long-term trend,
- lag-1 yield,
- selected conventional weather terms,
- retained extreme-weather indicators.

The final selection should be based on interpretive relevance rather than statistical significance alone.

### Visual design

Horizontal coefficient plot with:

- coefficient estimate,
- 95% OLS confidence interval,
- vertical zero-reference line.

Include a prominent note:

**Conditional predictive associations, not causal effects**

---

## 15. Difficult-Year Comparison Graphic

**Presentation slide:** Slide 23 – *The Difficult Years Were Not All the Same*  
**Decision:** Create new from Table 5 and difficult-year diagnostic outputs

### Years

- 2012
- 2013
- 2015

### Suggested structure

Three columns or cards showing:

- mean yield,
- year-to-year yield change,
- median model RMSE,
- most unusual weather conditions,
- best-performing specification.

### Main message

The most difficult prediction years represented different combinations of weather and yield behavior.

This supports the conclusion that there was no single universal “difficult-year” weather pattern.

---

## 16. Final Holdout KPI Summary

**Presentation slide:** Slide 24 – *Final Holdout: The Locked Model Generalized*  
**Decision:** Create new

Use large values:

**RMSE: 11.97 bu/acre**

**MAE: 9.79 bu/acre**

**Out-of-sample R²: 0.392**

Smaller context:

- 247 county-year observations
- 82 counties
- 2022–2025
- model specification locked before evaluation

Avoid describing the lower holdout RMSE as a percentage improvement over development validation.

---

## 17. Holdout Performance by Year

**Presentation slide:** Slide 25 – *Holdout Performance by Year*  
**Decision:** Create new

A simple line or bar chart is preferable to directly reproducing Table 6.

### RMSE

- 2022: 9.46
- 2023: 11.11
- 2024: 13.12
- 2025: 14.13

Consider adding MAE only if it does not clutter the slide.

Narration can explain year-specific bias rather than plotting several additional metrics.

---

## 18. Predictive Uncertainty Summary

**Presentation slide:** Slide 27 – *How Certain Were the Predictions?*  
**Decision:** Create new

Combine two different uncertainty concepts.

### Aggregate-performance uncertainty

County-clustered bootstrap:

- Development RMSE: 22.56  
  95% CI: 21.21–23.75

- Holdout RMSE: 11.97  
  95% CI: 11.18–12.77

### Individual-prediction uncertainty

- 95% prediction-interval coverage: 98.8%
- Mean interval width: 56.85 bushels per acre

### Main takeaway

**Stable aggregate performance does not mean that every individual county-year prediction is highly precise.**

This is more useful for presentation than displaying the complete Appendix A or C tables.

---

## 19. Research-Question Synthesis

**Presentation slide:** Slide 30 – *Answering the Research Question*  
**Decision:** Create new

Use three connected conclusions:

### Historical information mattered

The baseline already contained substantial information through county identity, long-term trend, and previous-year yield.

### Weather added predictive value

Group 3 substantially reduced prediction error relative to the historical baseline.

### The value was not uniform

Benefits varied by year, model family, and county.

This should function as the transition from Results to Discussion.

---

## 20. Limitations Summary

**Presentation slide:** Slide 31 – *Limitations*  
**Decision:** Create new

Use approximately five concise cards:

- Fixed calendar windows approximate crop development.
- Soil, management, irrigation, genetics, pests, and remote sensing were not modeled directly.
- Repeated county observations and shared year-level conditions create dependence.
- County-specific diagnostic precision varies because the panel is unbalanced.
- Predictive associations should not be interpreted as causal effects.

Avoid listing every thesis limitation.

---

## 21. Future-Directions Roadmap

**Presentation slide:** Slide 32 – *Future Directions*  
**Decision:** Create new

Possible branches:

- Phenology-informed weather windows
- Soil and management information
- Remote sensing
- Additional dependence-aware uncertainty methods
- Broader geographic validation

This slide should look forward rather than repeat the limitations slide.

---

## 22. Final Takeaway Graphic

**Presentation slide:** Slide 33 – *Final Takeaway*  
**Decision:** Create new

Three concise conclusions:

1. **Weather improved prediction beyond historical yield patterns.**
2. **Retained extreme-weather indicators provided important additional predictive information.**
3. **The interpretable Linear Regression Group 3 model provided the strongest overall development-stage performance and generalized successfully to the untouched final holdout.**

Include a smaller qualifier:

**Performance still varied by year and county, and the findings are predictive rather than causal.**

---

# Results That Should Be Emphasized

The following numerical results are considered presentation-priority results.

## Development-Stage Results

**Selected model:** Linear Regression Group 3

- RMSE: 22.56 bushels per acre
- MAE: 18.10
- Out-of-sample R²: 0.553
- RMSE reduction versus Group 1: approximately 37.6%
- MAE reduction versus Group 1: approximately 35.9%
- Best overall model in 6 of 10 development-validation years
- Strongest overall specification remained unchanged when 2012 was excluded

## Final Holdout Results

- Period: 2022–2025
- Observations: 247
- RMSE: 11.97
- MAE: 9.79
- Out-of-sample R²: 0.392
- Mean residual: approximately 0.79 bushels per acre
- No post-holdout model changes

## Spatial Results

- 89 counties had eligible Group 1 versus Group 3 spatial comparisons.
- Group 3 reduced county-level RMSE in 78 counties.
- This corresponds to approximately 87.6% of evaluated counties.
- Median county-level RMSE reduction: 11.33 bushels per acre.

## Predictive-Uncertainty Results

Development-stage RMSE:
- 22.56
- 95% county-cluster bootstrap CI: 21.21–23.75

Final-holdout RMSE:
- 11.97
- 95% county-cluster bootstrap CI: 11.18–12.77

Prediction intervals:
- 244 of 247 holdout observations covered
- 98.8% empirical coverage
- Mean interval width: 56.85 bushels per acre

---

# Results That Should Not Receive Major Slide Space

The following results should remain available for narration, backup slides, or questions but do not require dedicated main-presentation slides:

- Complete 102-coefficient final-model output
- All county indicator coefficients
- Complete Random Forest tuning results
- Complete XGBoost tuning results
- Full fold-specific hyperparameter histories
- Every residual diagnostic figure
- Complete influence-screening tables
- Complete county-level spatial tables
- Every difficult-year weather-feature standardized difference
- Full bootstrap tables for all three metrics
- Detailed reproducibility audit outputs

These materials strengthen the thesis and reproducibility package but would distract from the central presentation storyline if shown in full.

---

# Preliminary Visual Workload

## Existing Figures Requiring Only Minor Adaptation

- Figure 1
- Figure 5
- Figure 7
- Figure 8

## Existing Figure to Test Before Deciding Whether to Redesign

- Figure 4

## New Presentation-Specific Graphics to Create

1. Prediction-problem concept diagram
2. Three predictor-group diagram
3. Study-period timeline
4. Data-source integration diagram
5. Analytical-sample summary
6. Weather-window timeline
7. Extreme-weather feature summary
8. Model-family overview
9. Random-split versus time-aware-validation diagram
10. Expanding-window-validation diagram
11. Formal model-lock workflow
12. Random Forest/XGBoost comparison summary
13. Model-selection decision summary
14. Selected-coefficient forest plot
15. Difficult-year comparison
16. Final-holdout KPI summary
17. Holdout-year RMSE chart
18. Predictive-uncertainty summary
19. Research-question synthesis
20. Limitations summary
21. Future-directions roadmap
22. Final-takeaway graphic

Not all of these need to be elaborate standalone images. Many can be constructed directly in PowerPoint using shapes, text, arrows, and simple charts.

---

# Week 7 Status After Figure Selection

- [x] Initial presentation storyline established.
- [x] Initial slide outline created.
- [x] Final thesis figures selected for reuse.
- [x] Presentation-specific visuals identified.
- [x] Major numerical results selected for presentation.
- [x] Review the presentation outline against the presentation rubric.
- [ ] Prepare Week 7 GitHub evidence.
- [ ] Complete Weekly Status Report #7.

---

## Current Recommendation

The final narrated presentation should prioritize a relatively small number of strong analytical visuals rather than attempting to display every thesis result.

The central visual sequence should be:

**Three Predictor Groups → Time-Aware Validation → Model Lock → Development Model Comparison → Final Holdout → Predictive Uncertainty → Spatial Improvement → Final Research-Question Answer**

This sequence most directly supports the thesis research question while also demonstrating methodological rigor, statistical evidence, and appropriate interpretation.
