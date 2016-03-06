


class OcrInterface:
    """
    Clase para ser una interface del 
    OCR instalado en el SO utilizado
    """
    pass

class OcrConverter:
    out_format = "txt" #default output format
    in_dir = ""
    out_dir = ""
    def __init__(self, input_dir, output_dir):
        self.input_dir = input_dir
        self.output_dir = output_dir

    def convert(self):
        #agregar codigo para iterar en directorio de entrada

if __name__ = "__main__":
    #test code
    ocr = OcrConverter()
    ocr.convert()
