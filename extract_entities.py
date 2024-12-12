import os
from transformers import pipeline
from PyPDF2 import PdfReader

# Step 1: Define the NER pipeline using BioBERT
ner_pipeline = pipeline("ner", model="dmis-lab/biobert-base-cased-v1.1")

def extract_text_from_pdf(pdf_path):
    """Step 2: Extract text from PDF file"""
    pdf_reader = PdfReader(pdf_path)
    text = ""
    for page in pdf_reader.pages:
        text += page.extract_text()
    return text

def preprocess_text(text):
    """Step 3: Preprocess and clean text (optional)"""
    text = text.replace('\n', ' ')  # Removing newlines
    text = ' '.join(text.split())  # Removing extra spaces
    return text

def split_text_into_chunks(text, chunk_size=500):
    """Step 4: Split the text into smaller chunks"""
    chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
    return chunks

def process_pdf(pdf_path, output_path):
    """Step 5: Process each PDF and extract named entities"""
    text = extract_text_from_pdf(pdf_path)
    preprocessed_text = preprocess_text(text)
    text_chunks = split_text_into_chunks(preprocessed_text)
    
    all_entities = []
    for chunk in text_chunks:
        entities = ner_pipeline(chunk)
        all_entities.extend(entities)
    
    # Write the extracted entities to an output file
    with open(output_path, 'w') as f:
        f.write(f"Entities extracted from {os.path.basename(pdf_path)}:\n")
        for entity in all_entities:
            # Use a fallback mechanism to handle missing keys
            word = entity.get('word', 'N/A')
            label = entity.get('entity_group', entity.get('label', 'N/A'))
            score = entity.get('score', 0.0)
            
            f.write(f"Entity: {word}, Label: {label}, Score: {score:.4f}\n")
    
    print(f"Entities written to {output_path}")

def main():
    """Step 6: Main function to execute the processing"""
    pdf_folder = '/home/akkey/Akshay/Biobert/pdf'  # Folder with PDF files
    output_folder = '/home/akkey/Akshay/Biobert/output'  # Folder to store output text files

    os.makedirs(output_folder, exist_ok=True)
    
    # Loop through each PDF file in the pdf_folder
    for pdf_file in os.listdir(pdf_folder):
        if pdf_file.endswith('.pdf'):
            pdf_path = os.path.join(pdf_folder, pdf_file)
            output_file = os.path.join(output_folder, f"{pdf_file}_entities.txt")
            process_pdf(pdf_path, output_file)

if __name__ == "__main__":
    main()

