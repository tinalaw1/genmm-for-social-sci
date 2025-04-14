import os
from openai import OpenAI
import base64
import requests
import json
import time
import re

# Set API key
# Note: You will need to obtain an OpenAI API key.


# Set seed
# Note: We recommend setting a seed to support reproducibility of output.
SEED = 123

# Define function to encode satellite image
def encode_sat_image(sat_image_path):
  with open(sat_image_path, "rb") as image_file:
    return base64.b64encode(image_file.read()).decode('utf-8')

# Define function to encode streetscape image 1
def encode_st1_image(st1_image_path):
  with open(st1_image_path, "rb") as image_file:
    return base64.b64encode(image_file.read()).decode('utf-8')

# Define function to encode streetscape image 2
def encode_st2_image(st2_image_path):
  with open(st2_image_path, "rb") as image_file:
    return base64.b64encode(image_file.read()).decode('utf-8')

# Define file directory
# Note: You will need to set up a file directory for image data. File paths in API call may be different depending on file naming convention.
file_directory = "Documents/sample_directory"

# Record time before API call
start_time = time.time()

# Send call to API
# Note: This API call is set to use gpt-4o.
for site_id in os.listdir(file_directory):
  site_path = os.path.join(file_directory, site_id)
  if os.path.isdir(site_path):

    # Define file path for each image for a site
    satellite_pattern = re.compile(f"{site_id}_[0-9]+\\.png")
    st1_image_path = os.path.join(site_path, f"{site_id}_FT.png")
    st2_image_path = os.path.join(site_path, f"{site_id}_TF.png")

    sat_image_path = None
    for file_name in os.listdir(site_path):
      if satellite_pattern.match(file_name):
        sat_image_path = os.path.join(site_path, file_name)
        break

    # Check for sites that have three images
    if os.path.exists(sat_image_path) and os.path.exists(st1_image_path) and os.path.exists(st2_image_path):

      # Encode each image
      base64_sat_image = encode_sat_image(sat_image_path)
      base64_st1_image = encode_st1_image(st1_image_path)
      base64_st2_image = encode_st2_image(st2_image_path)

      headers = {
        "Content-Type": "application/json",
        } # Add API key authorization under headers parameter

      payload = {
        "model": "gpt-4o", # Change model as needed
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text": "You will be provided with three images of the same location. The first image is a satellite image and the second and third images are street-level images. Follow these instructions in order:\n1. For the satellite image, list one or more built environment features that specifically overlap with the red line in the center of the image only if the feature is in this list:\n- Multi-lane highway or freeway\n- Local or residential road\n- Railroad track\n- Other transportation infrastructure\n- Physical barrier (includes guardrail, bollard, fencing, or wall)\n- Street sign indicating no passage\n- Vegetation\n- Residential buildings and property\n- Community buildings and property\n- Industrial buildings and property\n- Other buildings and property\n- Recreational areas\n- Parking facility\n- Cemeteries\n- Industrial area that is not a building\n- Undeveloped land\n- Water body or waterway\n- Topographical feature\nDo not list features that do not overlap with the red line.\n2. For the street-level images, identify any features from the list that you did not identify in the satellite image, if there are any.\nSummarize unique features across the three images in one line of text with each feature separated by a comma. You do not need to provide summaries of each image."
                }
              ]
          },
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {
                  "url": f"data:image/jpeg;base64,{base64_sat_image}"
                  }
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": f"data:image/jpeg;base64,{base64_st1_image}"
                  }
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": f"data:image/jpeg;base64,{base64_st2_image}"
                  }
                }
              ]
            }
          ],
        "max_tokens": 40, # Adjust depending on image data and task
        "temperature": 0, # We recommend setting the temperature parameter to 0 to minimize output randomness
        "seed": SEED
        }

      response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
      response_data = response.json()

      # Specify directory for output
      output_directory = "Documents/sample_directory/output/"
      os.makedirs(output_directory, exist_ok=True)

      # Save response as .json file
      json_file_path = os.path.join(output_directory, f'response_{site_id}.json')
      with open(json_file_path, 'w') as json_file:
          json.dump(response_data, json_file, indent=4)

      print(f"Response for {site_id} saved to {json_file_path}")

# Record time after API call
end_time = time.time()

# Calculate and save API call execution time
execution_time = end_time - start_time

ex_time_file_path = os.path.join(output_directory, f'execution_time.txt')
with open(ex_time_file_path, 'w') as file:
  file.write(f"Execution Time: {execution_time} seconds")

