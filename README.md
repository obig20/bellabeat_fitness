# Bellabeat Fitness Tracker Case Study

Google Data Analytics Professional Certificate Capstone Project

## Overview
Analyzed public Fitbit Fitness Tracker Data to uncover usage trends in activity, sleep, sedentary behavior, and calories. Provided marketing recommendations for Bellabeat (women-focused wellness tech company).

Business Task: Identify smart device trends and apply insights to Bellabeat products (Leaf, Time, app) to guide marketing strategy.

## Tools & Tech Stack
- **SQL**: PostgreSQL/pgAdmin — data import, cleaning, aggregation (minute_sleep → daily sleep), merging
- **Python**: Jupyter Notebook (pandas, seaborn, matplotlib) — EDA, stats, visualizations
- **Tableau Public**: Interactive dashboard for sharing insights
- Data Source: Fitbit Fitness Tracker Data (Kaggle, CC0 Public Domain)

## Key Findings
- Average daily steps: ~6,547 (below 10k goal)
- Average sleep: 6.56 hours (short on many days)
- Higher activity & calorie burn on days with sleep tracked
- Mid-week (esp. Wednesday) shows best activity + sleep balance
- High sedentary time (~16–17 hrs/day) across most days

## Recommendations for Bellabeat
1. Promote overnight wear of Leaf/Time → better sleep tracking unlocks activity insights
2. Personalized notifications for low-activity days → target patterns like Tuesday dips
3. Focus marketing on holistic wellness → emphasize sleep-activity link for women

## Project Files
- `bellabeat_analysis.ipynb`: Python analysis & plots
- `SQL.sql`: SQL queries for data prep & merging
- `Tablue_Dashboard 1.png`: Screenshot of Tableau dashboard
- `data/`: Raw & processed CSVs

## Tableau Dashboard
Live version: https://public.tableau.com/app/profile/desalegn.tilahun/viz/Tablue_Google_dataanalytics/Dashboard1?publish=yes

## How to Run
1. Clone repo
2. Open `bellabeat_analysis.ipynb` in Jupyter
3. Ensure data files are in place
4. Run cells sequentially

License: MIT 
