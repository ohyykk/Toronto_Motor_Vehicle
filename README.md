# Hot Spots of Inequality: Urban Heat Islands and Socioeconomic Disparities in Toronto

## Overview

This repository contains the analysis for the paper **"Hot Spots of Inequality: Urban Heat Islands and Socioeconomic Disparities in Toronto."** The research examines the relationship between urban heat island (UHI) intensity, land use patterns, and socioeconomic factors across Toronto neighborhoods. By analyzing spatial and demographic data, the paper explores how urban heat is distributed and whether it disproportionately affects lower-income communities. 

A combination of statistical modeling and geospatial analysis is used to identify key factors contributing to UHI intensity and propose equitable mitigation strategies. 

## File Structure

The repository is organized as follows:

- `data/raw_data`: Contains the original datasets used for analysis, including temperature records, socioeconomic data, and green space maps. 
- `data/analysis_data`: Includes the processed and cleaned datasets used for analysis and modeling.
- `models`: Contains fitted statistical models, spatial models, and relevant outputs.
- `paper`: Contains all materials for the paper, including:
  - The Quarto document for drafting and compiling the paper.
  - The final PDF version of the paper.
  - Bibliography and citation files.
  - Supporting documents such as the datasheet for the dataset and appendices.
- `scripts`: Includes the R and Python scripts for data cleaning, analysis, and visualization. Specific scripts for geospatial mapping and statistical modeling are included.
- `figures`: Contains the figures, maps, and visualizations generated for the paper.
- `other`: Stores supplementary materials, including brainstorming sketches and documentation of interactions with language models.

## Tools and Methodology

The analysis involves:
1. **Geospatial Analysis**: Mapping UHI intensity across Toronto and overlaying socioeconomic and green space data.
2. **Statistical Modeling**: Using regression and spatial models to explore the relationships between UHI intensity, income levels, and land use patterns.
3. **Visualization**: Static plots are used to highlight the key findings.

Software tools used include:
- **R**: For statistical modeling, data manipulation, and visualizations (e.g., `ggplot2`).

## Statement on LLM Usage

The complete interaction history is documented in `other/llm_usage.txt` for transparency. 
