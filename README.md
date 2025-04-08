# Generative Mulitmodal Models for Social Science

## Overview

This repository provides sample code for implementing Law and Roberto's (2025) Social Science Framework for Image Analysis with Generative Multimodal Models. This framework, which extends Grimmer, Roberts, and Stewart's (2022) "agnostic approach" to computational text analysis, consists of three core tasks: (1) curation, (2) discovery, and (3) measurement and inference. For more information about this framework, please refer to the original paper (citation provided below). The sample code provided here demonstrates how to implement this framework with an empirical application that uses OpenAI's GPT-4o multimodal model to analyze satellite and streetscape images to identify built environment features that contribute to contemporary residential segregation in U.S. cities.

*Recommended citation* 
Law, Tina and Elizabeth Roberto. 2025. "Generative Multimodal Models for Social Science: An Application with Satellite and Street Imagery." [https://osf.io/preprints/socarxiv/6jq32](https://osf.io/preprints/socarxiv/6jq32)

## Framework with Example of Empirical Application

### Task 1: Curation

The first task is to collect relevant image data in a systematic and principled manner. Refer to the original paper for detailed guidance on how to collect images in a systematic and principled manner.

For our empirical application, we collected streetscape and satellite images that capture the built environment of socially and spatially divided sites in five U.S. cities that vary in demographics and spatial characteristics: Chicago, IL, Cincinnati, OH, Hartford, CT, Miami, FL, and Seattle, WA. We used the Counterfactual Road Networks method (Roberto et al. 2024) to identify socially and spatially divided sites in these cities. We selected a subset of sites that are most likely to be associated with residential segregation (*n* = 367). We used the geographic coordinates of these sites to collect streetscape and satellite images from the Google Maps API and the Google Cloud Platform. For each site, we collected one satellite image (centered on the site of division) and two streetscape images (from the vantage point of each endpoint of the site of division looking toward the other endpoint).

We are unable to share the streetscape and satellite images, but researchers can obtain these images from the Google Maps API and the Google Cloud Platform. The repository also contains a csv file containing geographic coordinates for sites in our test set (*n* = 49) and sample code for obtaining images from the APIs.

### Task 2: Discovery

The second task is to develop image labels and model prompts. We strongly encourage researchers to document their image label and model prompt development process, as well as to use API calls when possible, to support learning and reproducibility. Refer to the original paper for detailed guidance on how to create and test image labels with human coders and generative multimodal models, and how to create and test model prompts.

For our empirical application, we developed a list of 18 built environment feature labels using previous research on residential segregation, manual coding, and ChatGPT Plus. Our labels are provided in Table 4 of the original paper. We developed our model prompt after testing different prompts with ChatGPT Plus. Our model prompt is provided in the original paper as well as in our code for obtaining model-generated labels (discussed in Task 3: Measurement).

### Task 3: Measurement

The third task is to obtain and validate model-generated image labels. Refer to the original paper for detailed guidance on how to obtain model-generated labels (including how to ensure model labeling consistency) and assess the reliability and validity of model-generated labels. Researchers may opt to use validated labels to make inferences, though the original paper focuses only how to obtain and validate model-generated labels.

For our empirical application, we used gpt-4o-2025-05-2013, the latest version of GPT-4o at the time of our analysis, to obtain model-generated labels for all images (*n* = 1,101 satellite and streetscape images from 367 sites). Because generative AI models behave non-deterministically, we obtained three sets of model-generated labels for each site and used labels that were applied in at least two different runs for a given site to serve as our final set of model-generated labels. 

We randomly selected a subset of sites to serve as our test set (*n* = 49 sites). All images from the test set sites were labeled by a team of human coders using Dedoose software. In addition to "research assistant labels," we also obtained a set of "expert labels" based on labeling by one of the authors and a coder (who was not assigned to labeling tasks). We assessed whether our labels reliably measure well-defined built environment features by measuring between-research assistant agreement, and we assessed the validity of our model-generated labels by measuring accuracy, recall, precision, and F1 score. Our metrics for model labeling consistency, reliability, and validity are provided in Tables 5, 7, and 8, respectively, in the original paper. The proportion of sites with predicted and expert labels are also provided in Tables 6 and 8, respectively, in the original paper.

We provide sample code for using OpenAI's GPT-4o model to label images. Researchers can measure between-research assistant agreement by calculating pairwise agreement, or the percent of labels that match in presence (or absence) for each pair of human coders. Between-research assistant agreement can also be measured using Cohen's $\kappa$: 
$\kappa = \frac{P_0 - P_e}{1 - P_e}$
where $P_0$ is the observed proportion of agreement between two rates and $P_e$ is the expected proportion of agreement due to chance. 

Researchers can measure validity by comparing consistently generated model labels (predicted labels) and expert labels (expected labels) and calculating accuracy, recall, precision, and F1 scores. Accuracy is the overall proportion of images that are correctly labeled and can be calculated as:
$\text{Accuracy} = \frac{\text{True Positives} + \text{True Negatives}}{\text{True Positives} + \text{False Positives} + \text{True Negatives} + \text{False Negatives}}$
Precision is the proportion of images that are correctly labeled among true and false positives. Recall is the proportion of images that are correctly labeled among true positives and false negatives. F1 score is the harmonic mean of precision and recall values, which can be calculated as:
$F1 = 2 \times \frac{\text{precision} \times \text{recall}}{\text{precision} + \text{recall}}$.

