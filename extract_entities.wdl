version 1.0

workflow extract_entities_workflow {
  input {
    String pdf_folder
    String output_folder
  }

  # Task 1: Extract text from PDF
  call extract_text_from_pdf {
    input:
      pdf_folder = pdf_folder
  }

  # Task 2: Preprocess and clean the extracted text
  call preprocess_text {
    input:
      text = extract_text_from_pdf.text
  }

  # Task 3: Split the text into chunks for NER
  call split_text_into_chunks {
    input:
      text = preprocess_text.cleaned_text
  }

  # Task 4: Run NER on each chunk of text
  call run_ner {
    input:
      text_chunks = split_text_into_chunks.chunks
  }

  # Task 5: Write the results to the output file
  call write_entities_to_output {
    input:
      all_entities = run_ner.entities
      output_folder = output_folder
  }
}

# Task 1: Extract text from PDF using PyPDF2
task extract_text_from_pdf {
  input {
    String pdf_folder
  }

  output {
    String text
  }

  command {
    python3 extract_entities.py --pdf_folder ${pdf_folder}
  }

  runtime {
    docker: "python:3.8"
  }

  # We assume extract_entities.py is modified to return text output
}

# Task 2: Preprocess text (remove newlines and extra spaces)
task preprocess_text {
  input {
    String text
  }

  output {
    String cleaned_text
  }

  command {
    python3 -c "import sys; text = sys.stdin.read().replace('\\n', ' ').replace('  ', ' '); sys.stdout.write(text)"
  }

  runtime {
    docker: "python:3.8"
  }
}

# Task 3: Split text into chunks
task split_text_into_chunks {
  input {
    String text
  }

  output {
    Array[String] chunks
  }

  command {
    python3 -c "
import sys
text = sys.stdin.read()
chunk_size = 500
chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
sys.stdout.write('\\n'.join(chunks))
" 
  }

  runtime {
    docker: "python:3.8"
  }
}

# Task 4: Run NER using BioBERT
task run_ner {
  input {
    Array[String] text_chunks
  }

  output {
    Array[String] entities
  }

  command {
    python3 -c "
from transformers import pipeline
ner_pipeline = pipeline('ner', model='dmis-lab/biobert-base-cased-v1.1')

entities = []
for chunk in ${' '.join(text_chunks)}:
    result = ner_pipeline(chunk)
    for entity in result:
        entities.append(f'Entity: {entity.get('word')}, Label: {entity.get('entity_group')}, Score: {entity.get('score')}')
sys.stdout.write('\\n'.join(entities))
"
  }

  runtime {
    docker: "huggingface/transformers-pytorch-cpu:latest"
  }
}

# Task 5: Write the NER output to a file
task write_entities_to_output {
  input {
    Array[String] all_entities
    String output_folder
  }

  output {
    File output_file
  }

  command {
    echo "Entities extracted:" > ${output_folder}/extracted_entities.txt
    for entity in "${all_entities[@]}"
    do
      echo "$entity" >> ${output_folder}/extracted_entities.txt
    done
  }

  runtime {
    docker: "python:3.8"
  }
}
