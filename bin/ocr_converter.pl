#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use File::Basename;

#################################################################
###########Global Variables#############
my @languages_list;
my @ocrs_list;
my @formats_list;
my @imagenes_list;
my @dirs_list;
####### Read input arguments   #####
my $opt_help = undef;
my $input_dir = undef;
my $ocrs = undef;
my $output_dir = undef;
my $formats = undef;
my @args = @ARGV;
GetOptions('help'=> \$opt_help,
            'input_dir=s'=> \$input_dir,
            'ocrs=s'=>\$ocrs,
            'output_dir=s'=>\$output_dir,
            'formats=s' => \$formats,
        );
#################################################################
##########        MAIN        ##########
&process_args();
&convert_dirs();


###################################################################
sub process_args(){
#Ayuda
	&print_help() if (defined $opt_help);
#Si no hay carpeta qué procesar, salir con error.
	die("Se necesita una carpeta con imágenes para usar el programa") if(!defined $input_dir);
#Se pueden usar más de un convertidor
	$ocrs = "t" if(!defined $ocrs);
	@ocrs_list = split(/\,/,$ocrs);
#Asignar la carpeta de salida en base a la de entrada si no se define
	($output_dir = $input_dir) =~ s/(.*)/$1_convertido/ if (!defined $output_dir);
#Para elformato se pueden ahora escoger varios y se creará una carpeta con cada uno de ellos.
	$formats = "txt" if(!defined $formats);
	@formats_list = split(/\,/,$formats);

	@imagenes_list = `ls $input_dir`;
	foreach my $imagen (@imagenes_list){
		$imagen =~ s/ /\\ /g; chomp $imagen;
	}
}

sub convert(){
  my $dir_input = $_[0];
	my $imagen; my $conversion; my $command;
	my $current_dir; my $formato2; my $ocr;
	foreach my $formato (@formats_list){
		$formato2 = "TXT" if($formato eq "txt");
		$formato2 = "PDF" if($formato eq "pdf");
    print("\n---------------------------------------------------------------\n");
    print("\n\t\t-----Convirtiendo a $formato------\n");
    print("\n---------------------------------------------------------------\n");
		foreach $ocr (@ocrs_list){
			$ocr = "Tesseract" if($ocr eq "t");
			$ocr = "GOCR" if($ocr eq "g");
			$ocr = "Ocrad" if($ocr eq "o");
			$current_dir = "$output_dir/$formato/$ocr";
			print("\n\t\t |---Usando OCR: $ocr---|\n\n");
			print("Creando directorio: $current_dir\n");
			`mkdir -p $current_dir`;
			foreach $imagen (@imagenes_list){
				($conversion = $imagen ) =~ s/.jpg/.$formato/;
				print("Convirtiendo $imagen a $conversion en $current_dir\n");
				$command = "ocrfeeder-cli --image $dir_input/$imagen -f $formato2 -o $current_dir/$conversion -e $ocr -l es";
				print("Usando commando:\n>$command\n");
  `$command`;
			}
		}
	}
    print("\n---------------------------------------------------------------\n");
	print("Imágenes convertidas!\nEn la carpeta $output_dir puede encontrar los archivos finales.\n");
    print("---------------------------------------------------------------\n");
}

sub print_help(){
    my $message=shift;
    print <<HELP;
    Este script convierte una serie de imagenes de texto a archivos txt o pdf
    usando OCRS libres.
    Opciones:
    --help              Print this help message and exit.
    --input_dir <path>  El path que contenga las carpetas a convertir.
    --ocrs "t,o,g"      Usar una o varias. Ejmplo: --ocrs t, --ocrs "t,o".
    --output_dir <path> Path en donde se guardarán las conversiones.
    --formats "txt,pdf" Formatos a usar. Uno o varios. Ejemplo: --formats txt.
    Por default --ocrs es t (Tesseract), --output_dir es <input_dir>_convertido, --formats es txt.
HELP
    print("\n$message\n") if (defined $message);
    exit 0;
}

sub convert_dirs(){
	@dirs_list = `ls $input_dir`;
	foreach my $dir (@dirs_list){
		&convert("$input_dir/$dir") if(-d "$input_dir/$dir");
	}
}
