# Final Narrated Presentation Rubric Crosswalk

**Project:** Weathering the Yield: Predicting Indiana Corn Yield with Growing-Season Weather Extremes  
**Course:** INFO-I 492 Senior Thesis  
**Prepared:** November 2, 2026  
**Presentation Due:** December 10, 2026  
**Required Length:** 40–60 minutes  
**Status:** Week 7 rubric-alignment review

---

## Purpose

This document compares the planned final narrated thesis presentation with the grading requirements for Assignment 5: Final Thesis Narrated Presentation.

The goal is to verify that the planned presentation addresses every rubric criterion before slide development begins and to identify any areas that should be strengthened in the initial slide outline.

The assignment requires a narrated presentation that explains the complete research project clearly enough for an audience unfamiliar with the topic, with narration on every slide and a total presentation length of 40–60 minutes.

---

# Overall Rubric Alignment

The planned 34-slide presentation addresses all major assignment content requirements:

- Introduction
- Background
- Hypothesis
- Literature Review
- Methodology
- Descriptive Statistics
- Inferential Statistics
- Discussion and Implications
- Conclusion and Future Research
- Professional Delivery

The initial outline is therefore structurally well aligned with the assignment.

Three areas should be strengthened before slide production:

1. Make the personal or academic reason for selecting the research topic explicit in the Introduction.
2. Ensure the descriptive-statistics portion includes a clearly identifiable quantitative table or figure rather than only verbal sample counts.
3. Explicitly reconnect the thesis findings to secondary literature during the Discussion rather than limiting literature references to the earlier Literature Review section.

---

# Rubric Crosswalk

## 1. Introduction — 5 Points

### Rubric expectation

For the highest rating, the presentation should clearly state:

- the research problem, and
- the reasons or inspiration for conducting research on the topic.

### Planned coverage

**Slide 1 – Weathering the Yield**
- Introduces the presenter and thesis project.

**Slide 2 – Why Predict Corn Yield?**
- Establishes the importance of Indiana corn production.
- Introduces county-level yield variability.
- Explains why prediction is useful.

**Slide 3 – The Prediction Problem**
- Explains why historical yield information alone may not fully represent current growing-season conditions.

### Alignment

**Mostly meets / should be strengthened for Exceeds Standards.**

The research problem is clearly covered, but the initial outline does not yet explicitly state why this topic was personally or academically selected.

### Recommended adjustment

Add a brief component to Slide 2 such as:

**Why I chose this topic**

Explain that the project provided an opportunity to combine interests in predictive modeling, weather variability, agriculture, and a problem with direct relevance to Indiana.

The explanation should be genuine and brief rather than overly personal.

### Final target

**Exceeds Standards**

---

## 2. Background — 5 Points

### Rubric expectation

Provide appropriate context and background information for the research.

### Planned coverage

**Slides 2–6**

- Why corn-yield prediction matters.
- County-level yield variability.
- Historical yield as a useful baseline.
- Growing-season temperature and precipitation.
- Importance of weather timing.
- Extreme heat, drought, and excessive moisture.
- Research gap motivating the study.

### Alignment

**Strongly aligned.**

The planned sequence establishes context before introducing technical methodology.

### Final target

**Full Marks**

---

## 3. Hypothesis — 5 Points

### Rubric expectation

The hypothesis must be clearly stated.

### Planned coverage

**Slide 4 – Research Question & Hypothesis**

Research question:

> To what extent do growing-season weather conditions and extreme-weather indicators improve the prediction of Indiana county-level corn yields beyond historical yield patterns?

Hypothesis:

> Incorporating growing-season weather and extreme-weather indicators will improve predictive performance compared with a model using historical yield information alone.

### Alignment

**Fully aligned.**

### Presentation note

The hypothesis should appear visibly on the slide rather than being provided only through narration.

### Final target

**Full Marks**

---

## 4. Body: Methodology — 5 Points

### Rubric expectation

For the highest rating, the presentation should clearly explain:

- variables of interest,
- why the variables are appropriate,
- population/sample,
- methods used,
- resulting sample, and
- relevant methodology or analysis issues.

### Planned coverage

**Slides 7–16**

### Study design
Slide 7 – Study Design at a Glance

### Data sources
Slide 8 – Data Sources

- USDA NASS Quick Stats
- NOAA nClimGrid-Daily
- EpiNOAA

### Sample
Slide 9 – Analytical Sample

- 1,691 development county-year observations
- 91 development counties
- 247 final-holdout observations
- 82 holdout counties
- naturally unbalanced county-year panel

### Variables
Slides 10–12

- historical predictors,
- conventional weather predictors,
- extreme-weather predictors,
- weather windows,
- multicollinearity refinement.

### Modeling
Slide 13

- Linear Regression
- Random Forest
- XGBoost

### Validation methodology
Slides 14–16

- why random splitting was inappropriate,
- expanding-window validation,
- reserved holdout,
- formal model lock.

### Relevant methodological issues

The presentation will explain:

- temporal information leakage,
- multicollinearity,
- unbalanced county-year observations,
- unseen county handling where relevant,
- need to keep the final holdout untouched.

### Alignment

**Very strong.**

This is one of the strongest areas of the planned presentation.

### Final target

**Exceeds Standards**

---

## 5. Literature Review — 5 Points

### Rubric expectation

Summarize the key findings from the literature review.

### Planned coverage

**Slide 5 – What Previous Research Tells Us**

Primary themes:

- timing of weather exposure matters,
- reproductive and early grain-filling periods are especially important,
- extreme heat provides information beyond average temperature,
- drought and moisture conditions affect yield,
- excessive rainfall can also be damaging.

**Slide 6 – The Research Gap**

Explains how previous research motivated the controlled comparison of nested predictor groups.

### Alignment

**Fully aligned.**

### Presentation recommendation

Do not attempt to summarize every article individually.

Instead, organize the literature around approximately four major themes and show a small number of representative citations.

### Final target

**Full Marks**

---

## 6. Body: Descriptive Statistics — 5 Points

### Rubric expectation

For the highest rating, the presentation should correctly present and explain relevant descriptive analyses of the sample, including an appropriate table or figure of quantitative data.

### Planned coverage

**Slide 9 – Analytical Sample**

Planned descriptive information:

- 1,691 development observations,
- 91 development counties,
- 247 holdout observations,
- 82 holdout counties,
- study periods.

**Slide 23 – The Difficult Years Were Not All the Same**

Includes descriptive yield and weather information for 2012, 2013, and 2015.

### Alignment

**Covered, but should be made more explicit.**

Simply displaying sample sizes may not be enough to make the descriptive-statistics rubric requirement unmistakable.

### Recommended adjustment

Design Slide 9 as a true **descriptive-statistics slide**, not merely a sample-size slide.

Include at least one quantitative visual or small table describing the observed data.

Possible content:

- development and holdout sample sizes,
- county coverage,
- year coverage,
- observed yield summary,
- potentially a simple observed-yield distribution or year-level yield graphic.

The audience should be able to identify this clearly as descriptive analysis.

### Final target

**Exceeds Standards**

---

## 7. Body: Inferential Statistics — 5 Points

### Rubric expectation

For the highest rating, the presentation should:

- correctly present relevant inferential statistics,
- show the inferential evidence clearly,
- and explain what the results mean.

The rubric specifically references examples such as confidence intervals and hypothesis tests.

### Planned coverage

**Slide 21 – What the Final Linear Model Says**

Presentation-specific coefficient forest plot showing:

- selected coefficient estimates,
- model-based 95% confidence intervals,
- zero-reference line.

**Slide 22 – Association, Not Causation**

Clarifies interpretation of those coefficients.

**Slide 27 – How Certain Were the Predictions?**

County-clustered bootstrap confidence intervals for predictive performance.

Examples:

Development RMSE:

- Estimate: 22.56
- 95% bootstrap CI: 21.21–23.75

Final holdout RMSE:

- Estimate: 11.97
- 95% bootstrap CI: 11.18–12.77

### Alignment

**Strongly aligned, provided the inferential process is explicitly explained.**

### Important presentation treatment

The presentation should explain that there are two different types of uncertainty being shown:

**Coefficient uncertainty**
- conventional model-based OLS confidence intervals.

**Predictive-performance uncertainty**
- county-clustered bootstrap confidence intervals.

These should not be presented as causal hypothesis tests.

### Recommended narration

Explain:

1. what the interval represents,
2. how it was calculated at a high level,
3. what the result means,
4. what it does not mean.

### Final target

**Exceeds Standards**

---

## 8. Discussion of Implications — 5 Points

### Rubric expectation

For the highest rating, the discussion should:

- thoughtfully explain implications,
- connect results with secondary sources,
- and provide clear and meaningful audience takeaways.

### Planned coverage

**Slide 30 – Answering the Research Question**

- historical information mattered,
- weather added predictive information,
- extreme-weather indicators added further value,
- benefits varied across years and counties.

**Slides 28–29**

Spatial implications.

**Slide 31 – Limitations**

Methodological interpretation.

### Alignment

**Strong, but one component needs to be made more explicit.**

The initial outline discusses implications well but does not explicitly designate a point where the final findings are compared back to secondary literature.

### Recommended adjustment

Either revise Slide 30 or add a short component within the Discussion titled:

**How these findings compare with previous research**

Briefly connect the results to themes such as:

- importance of weather timing,
- sensitivity to heat and moisture stress,
- value of historical yield information,
- variability in predictive performance across years and locations.

Use only a few highly relevant secondary sources.

This is not a second Literature Review. It demonstrates that the final results are being interpreted within the existing research context.

### Final target

**Exceeds Standards**

---

## 9. Delivery — 5 Points

### Rubric expectation

For the highest rating:

- professional and informative delivery,
- effective style and emphasis,
- useful visuals,
- audience engagement,
- presentation within the required time limit.

### Planned design

- 34 slides
- approximately 47–50 minutes
- narration on every slide
- accessible explanations for a nontechnical audience
- visuals used instead of manuscript-length text
- technical terminology defined when introduced

### Alignment

**Well positioned, but this criterion can only be fully evaluated after slides and narration are developed.**

### Quality-control actions

Before submission:

- Practice the full presentation.
- Confirm duration is between 40 and 60 minutes.
- Avoid reading slide text verbatim.
- Explain figures rather than merely describing axes.
- Use conversational transitions between sections.
- Test audio volume and clarity.
- If practical, have someone unfamiliar with the project watch part or all of the presentation.
- Verify narration exists on every slide.

### Final target

**Exceeds Standards**

---

## 10. Conclusion — 5 Points

### Rubric expectation

Summarize the main findings and suggest future research directions.

### Planned coverage

**Slide 32 – Future Directions**

Potential extensions:

- phenology-informed weather windows,
- soil and management information,
- remote sensing,
- dependence-aware uncertainty methods,
- broader geographic validation.

**Slide 33 – Final Takeaway**

Summarizes:

1. Weather improved prediction beyond historical yield.
2. Retained extreme-weather indicators provided additional information.
3. Linear Regression Group 3 produced the strongest development-stage performance and generalized successfully to the untouched holdout.

### Alignment

**Fully aligned.**

### Final target

**Full Marks**

---

# Assignment Instruction Crosswalk

In addition to the scored rubric, the assignment instructions require the following.

| Assignment Requirement | Planned Coverage | Status |
|---|---|---|
| Introduce yourself and research topic | Slide 1 | Covered |
| Background information | Slides 2–3 and 5–6 | Covered |
| Clearly state hypothesis | Slide 4 | Covered |
| Literature review | Slides 5–6 | Covered |
| Explain dataset | Slides 7–9 | Covered |
| Explain tools and methods | Slides 8–16 | Covered |
| Present results with tables/graphs/charts | Slides 17–29 | Covered |
| Interpret findings | Slides 30–31 | Covered |
| Relate findings to hypothesis | Slides 30 and 33 | Covered |
| Summarize main findings | Slides 30 and 33 | Covered |
| Future research | Slide 32 | Covered |
| Narration on every slide | To be completed during recording | Pending |
| 40–60 minute duration | Planned ~47–50 minutes | On target |
| Understandable to unfamiliar audience | Central presentation-design goal | On target |
| Microsoft PowerPoint or Google Slides | PowerPoint planned | Covered |
| Required file naming convention | Verify before final submission | Pending |

---

# Outline Adjustments Recommended Before Slide Development

## Adjustment 1 – Strengthen Slide 2

Current:

**Why Predict Corn Yield?**

Add:

**Why I chose this research topic**

Include a brief explanation of the motivation or inspiration for the project.

This directly addresses the Introduction rubric.

---

## Adjustment 2 – Strengthen Slide 9

Rename or expand:

**Analytical Sample & Descriptive Statistics**

Include a clearly recognizable quantitative table or graphic in addition to sample counts.

This directly addresses the Descriptive Statistics rubric.

---

## Adjustment 3 – Strengthen Slide 30

Current:

**Answering the Research Question**

Expand the discussion to include:

**Connection to Previous Research**

Use a small number of secondary sources to show how the final findings relate to existing research.

This directly addresses the highest-level Discussion of Implications criterion.

---

## Adjustment 4 – Make Inferential Statistics Explicit

Slides 21, 22, and 27 already contain appropriate material.

During slide development, clearly label the inferential evidence rather than assuming the grader will infer that coefficient confidence intervals and bootstrap intervals satisfy this rubric category.

The audience should understand:

- what estimate is being evaluated,
- what the confidence interval represents,
- and why the result should not be interpreted causally.

---

# Overall Rubric Assessment

The initial 34-slide presentation plan is well aligned with the final assignment requirements.

No major new presentation section is required.

The strongest areas of the current plan are:

- methodology,
- model-development safeguards,
- model comparison,
- final holdout evaluation,
- interpretation of predictive performance.

The three most important refinements before slide production are:

1. explicitly communicate the reason or inspiration for choosing the research topic,
2. make the descriptive-statistics evidence visually unmistakable,
3. reconnect the final results with secondary literature during the Discussion.

With these adjustments incorporated, the presentation structure is positioned to address every scored rubric category at the highest performance level.

---

# Week 7 Status After Rubric Review

- [x] Initial presentation storyline established.
- [x] Initial slide outline created.
- [x] Final thesis figures selected for reuse.
- [x] Presentation-specific visuals identified.
- [x] Major numerical results selected.
- [x] Presentation outline reviewed against the assignment rubric.
- [x] Rubric-related gaps identified and addressed in the development plan.
- [ ] Update the presentation outline with the three recommended refinements.
- [ ] Prepare Week 7 GitHub evidence.
- [ ] Complete Weekly Status Report #7.
