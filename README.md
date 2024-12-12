# PDF Named Entity Recognition (NER) with BioBERT

This repository provides a workflow for extracting named entities from PDF documents using the BioBERT model. The workflow is implemented in **Python** for text extraction and **WDL** (Workflow Description Language) for orchestration, making use of **Cromwell** or **MiniWDL** for execution.

## Overview

The goal of this project is to extract named entities such as genes, diseases, and other biological terms from scientific PDFs. We achieve this by:

1. **Extracting text** from PDF files.
2. **Preprocessing** the text (e.g., cleaning unwanted characters and formatting).
3. **Splitting** the text into manageable chunks.
4. **Running Named Entity Recognition (NER)** using the BioBERT model to identify relevant entities.
5. **Writing the extracted entities** to a specified output folder.

### Features:
- Handles large PDF documents by splitting the text into chunks.
- Uses **BioBERT** for domain-specific NER.
- Can be run using **Cromwell** or **MiniWDL** for workflow execution.
- Allows easy integration with other bioinformatics tools and pipelines.

## Requirements

### Prerequisites

1. **Python 3.8+** with the following dependencies:
    - `transformers` (for BioBERT)
    - `PyPDF2` (for PDF text extraction)
    - Docker (for containerized execution)
    
2. **Cromwell** or **MiniWDL** for running the WDL workflow.

3. **Docker**: Required for containerized execution of the tasks in the WDL script.

### Python Dependencies

To install the required Python dependencies, create a virtual environment and install the packages:

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install the dependencies
pip install -r requirements.txt
```

### WDL Execution Dependencies

To execute the WDL workflow, you will need **Cromwell** or **MiniWDL** installed.

1. **Install Cromwell**: Follow the installation guide [here](https://github.com/broadinstitute/cromwell/releases).

2. **Install MiniWDL**: Follow the installation instructions [here](https://github.com/openwdl/miniwdl).

### Docker Images

The WDL tasks utilize Docker containers to run Python scripts and BioBERT. Ensure that Docker is installed and running on your system. The following Docker containers are used:

- `python:3.8`
- `huggingface/transformers-pytorch-cpu:latest`

## Usage

### Step 1: Set Up the Environment

Clone this repository and set up the environment:

```bash
git clone https://github.com/yourusername/pdf-ner-biobert.git
cd pdf-ner-biobert
```

### Step 2: Prepare the PDFs

Place all your PDF files in the `pdf_folder`. For example, you can organize the files like this:

```
/path/to/pdfs/
    ├── paper1.pdf
    ├── paper2.pdf
    └── paper3.pdf
```

### Step 3: Configure the Workflow Inputs

Create a JSON file (e.g., `inputs.json`) with the paths to your PDF folder and the output folder:

```json
{
  "extract_entities_workflow.pdf_folder": "/path/to/pdfs",
  "extract_entities_workflow.output_folder": "/path/to/output"
}
```

### Step 4: Run the Workflow

Run the workflow using **Cromwell** or **MiniWDL**. If you're using **Cromwell**, execute the following:

```bash
java -jar cromwell-<version>.jar run extract_entities.wdl --inputs inputs.json
```

If you're using **MiniWDL**, execute the following:

```bash
miniwdl run extract_entities.wdl inputs.json
```

This will execute the workflow, extract entities from the PDFs in the specified folder, and write the results to the `output_folder`.

### Step 5: Check the Output

The extracted entities will be written to a text file in the specified `output_folder`. For example:

```
/path/to/output/
    ├── paper1_entities.txt
    ├── paper2_entities.txt
    └── paper3_entities.txt
```

Each file will contain the named entities extracted from the corresponding PDF.

## Directory Structure

The project contains the following key directories and files:

```
pdf-ner-biobert/
├── extract_entities.py         # Python script for extracting text from PDFs
├── extract_entities.wdl        # WDL workflow for PDF processing and NER
├── requirements.txt            # Python dependencies
├── inputs.json                 # Example input file for the WDL workflow
├── README.md                   # This file
└── output/                     # Folder to store the output files
    ├── paper1_entities.txt
    └── paper2_entities.txt
```

## Customization

- You can modify the Python script (`extract_entities.py`) to handle other types of documents or to integrate with additional bioinformatics tools.
- The `chunk_size` in the WDL workflow can be adjusted depending on the PDF size and the memory limits.

## Troubleshooting

1. **Missing Docker Images**: If Docker images are not pulled automatically, manually pull the required Docker images:
   ```bash
   docker pull python:3.8
   docker pull huggingface/transformers-pytorch-cpu:latest
   ```

2. **Memory Issues**: If you encounter memory issues, consider adjusting the chunk size in the WDL script to process smaller portions of text.

3. **Error in Extracting Text**: If the text extraction from PDF is not working well, try using different PDF extraction methods or libraries (e.g., `pdfplumber`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
