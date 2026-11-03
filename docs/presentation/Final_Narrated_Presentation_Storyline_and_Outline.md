# Final Narrated Presentation Storyline and Slide Outline

**Project:** Weathering the Yield: Predicting Indiana Corn Yield with Growing-Season Weather Extremes  
**Course:** INFO-I 492 Senior Thesis  
**Prepared:** November 2, 2026  
**Presentation Due:** December 10, 2026  
**Required Length:** 40–60 minutes  
**Status:** Initial Week 7 presentation plan

---

## Purpose

This document establishes the initial storyline and slide structure for the final narrated senior-thesis presentation. The presentation will serve as the asynchronous equivalent of an oral thesis defense and will communicate the completed research project to an audience that may not already be familiar with agricultural modeling or data science.

The outline is based on the finalized thesis results. Presentation development will prioritize clear explanation of the research question, methodological decisions, model comparison, final holdout evaluation, diagnostics, limitations, and conclusions rather than reproducing the written thesis slide by slide.

---

## Presentation Storyline

**Problem → Why weather may add value → How the question was tested fairly → Which model performed best → Whether it generalized → Where it struggled → What the results mean**

The presentation should emphasize that the primary contribution is not simply the performance of one model, but the controlled evaluation of whether increasingly detailed weather information improves prediction beyond a competitive historical-yield baseline under a time-aware validation framework.

---

## Initial Slide Outline

| # | Slide | Purpose / Key Content | Planned Visual | Target Time |
|---|---|---|---|---|
| 1 | **Weathering the Yield** | Title, your name, program, advisor; one-sentence thesis premise | Clean title slide | 0:45 |
| 2 | **Why Predict Corn Yield?** | Indiana context; county yields vary substantially across years; prediction has practical value | Indiana/corn visual or simple contextual graphic | 1:30 |
| 3 | **The Prediction Problem** | Historical yield is informative, but it cannot fully describe the weather experienced in a new growing season | Simple “Historical information + Current-season weather → Yield prediction” diagram | 1:30 |
| 4 | **Research Question & Hypothesis** | State the exact question; hypothesis that weather/extreme-weather indicators improve prediction beyond historical yield alone | Large concise text + three-group concept | 1:30 |
| 5 | **What Previous Research Tells Us** | Weather timing matters; reproductive/grain-fill periods matter; heat, drought, and excess moisture matter | 3–4 literature themes rather than citations-heavy slide | 2:00 |
| 6 | **The Research Gap** | Many studies combine many information sources; fewer isolate whether interpretable weather features add value beyond a strong historical baseline under the same forward-looking evaluation | Baseline → + weather → + extremes progression | 1:30 |
| 7 | **Study Design at a Glance** | Indiana, 2000–2025; development vs holdout; county-year structure | Timeline from 2000–2025 | 1:30 |
| 8 | **Data Sources** | USDA NASS yield + NOAA nClimGrid-Daily via EpiNOAA | Two-source diagram merging into modeling dataset | 1:30 |
| 9 | **Analytical Sample** | 1,691 development observations/91 counties; 247 holdout observations/82 counties; unbalanced panel | Small descriptive-statistics panel + Indiana map if useful | 1:30 |
| 10 | **Three Predictor Groups** | Group 1 historical; Group 2 + conventional weather; Group 3 + extremes | Layered three-tier graphic | 1:45 |
| 11 | **Weather Windows** | Early season, reproductive period, grain filling; explain why timing matters | Seasonal timeline May–September | 1:45 |
| 12 | **Extreme-Weather Features** | Heat >35°C accumulation, longest Jul–Aug dry spell, max 5-day precipitation; hot-day count excluded after multicollinearity audit | Three feature icons / concise definitions | 1:45 |
| 13 | **Three Modeling Approaches** | Linear Regression, Random Forest, XGBoost in audience-friendly language | Three-column comparison | 1:30 |
| 14 | **Why Random Splitting Would Be Misleading** | Future prediction requires preserving time order | Wrong: random split vs Right: expanding window | 1:45 |
| 15 | **Expanding-Window Validation** | 2012–2021 validation; earlier years train each future year | Animated/stepwise timeline | 2:00 |
| 16 | **Protecting the Final Test** | 2022–2025 kept untouched; formal model lock before holdout | Development → LOCK → Holdout diagram | 1:45 |
| 17 | **Linear Regression: Adding Weather Helped** | Group 3 pooled RMSE 22.56 vs 36.14 Group 1; strongest linear specification | **Figure 1**, presentation-adapted | 2:00 |
| 18 | **What Happened with Random Forest and XGBoost?** | Both benefited from richer predictor groups, but neither beat LR Group 3 overall | Concise comparison table or paired summary | 1:45 |
| 19 | **All Nine Models Compared** | Show the complete algorithm × predictor-group comparison; LR G3 ranked first on pooled RMSE, MAE, R² | **Figure 4** or a simplified ranked chart | 2:30 |
| 20 | **Why Linear Regression Group 3 Was Selected** | Best pooled RMSE/MAE/R²; best overall in 6/10 years; remained strongest excluding 2012 | Decision-summary slide | 1:45 |
| 21 | **What the Final Linear Model Says** | Selected coefficients + 95% CIs; focus on a few meaningful weather terms, not all 12 | Forest plot for ~5–6 coefficients | 2:00 |
| 22 | **Important Interpretation: Association, Not Causation** | Coefficients are conditional predictive associations; standard OLS intervals not fully dependence-adjusted | Simple caution/interpretation box | 1:15 |
| 23 | **The Difficult Years Were Not All the Same** | 2012, 2013, 2015; different weather/yield patterns; no single recurring failure mode | Three-year comparison graphic based on Table 5 | 2:15 |
| 24 | **Final Holdout: The Locked Model Generalized** | 2022–2025 pooled RMSE 11.97, MAE 9.79, R² .392; 247 obs | Large KPI-style metrics + model-lock reminder | 2:00 |
| 25 | **Holdout Performance by Year** | RMSE 9.46, 11.11, 13.12, 14.13; bias changed direction by year | Simplified Table 6 or compact chart | 1:45 |
| 26 | **Observed vs. Predicted Yield** | Show fit across 2022–2025; predictions somewhat compressed toward mean | **Figure 5** | 1:45 |
| 27 | **How Certain Were the Predictions?** | Bootstrap intervals + 98.8% PI coverage; mean prediction-interval width 56.85 bu/acre; good aggregate performance ≠ precise individual predictions | Simple uncertainty summary, possibly adapted C5 | 2:00 |
| 28 | **Where Did the Model Perform Better or Worse?** | County RMSE map; establish spatial heterogeneity | **Figure 7** | 1:45 |
| 29 | **Did Weather Help Across Indiana?** | Group 3 lowered county RMSE in 78/89 counties = 87.6%; improvement varied spatially | **Figure 8** | 2:00 |
| 30 | **Answering the Research Question** | Yes: adding growing-season weather, especially retained extremes, added predictive information beyond historical yield; benefit depended on model/year/county | One-slide synthesis | 1:45 |
| 31 | **Limitations** | Fixed calendar windows; omitted soil/management/etc.; repeated county/shared-year dependence; short holdout; prediction not causation | 4–5 concise limitation cards | 1:45 |
| 32 | **Future Directions** | Phenology-aware timing, soils/management/remote sensing, dependence-aware inference, broader geography | Roadmap graphic | 1:30 |
| 33 | **Final Takeaway** | Strong final message: interpretable weather information improved prediction, simpler LR generalized best, but uncertainty and context matter | 3 takeaway statements | 1:15 |
| 34 | **Thank You / Questions** | Advisor acknowledgment, optional repository/supplementary-material link | Minimal closing slide | 0:30 |

## Preliminary Figure Candidates

- Figure 1 – Linear Regression RMSE by predictor group
- Figure 4 – Cross-model-family RMSE comparison
- Figure 5 – Observed versus predicted final-holdout yield
- Figure 7 – County-level Group 3 RMSE
- Figure 8 – County-level RMSE change from Group 1 to Group 3
- Selected Appendix B coefficient results
- Selected Appendix A/C uncertainty results

## Presentation-Specific Visuals to Consider

- Study-design timeline
- Three predictor-group diagram
- Growing-season weather-window timeline
- Model-lock / holdout workflow
- Simplified model-ranking graphic
- Difficult-year comparison graphic
- Selected-coefficient forest plot
- Final-results summary slide

## Week 7 Status

- [x] Initial presentation storyline established.
- [x] Initial slide outline created.
- [ ] Select final thesis figures for reuse.
- [ ] Identify presentation-specific figures requiring adaptation or creation.
- [ ] Review outline against the presentation rubric.
