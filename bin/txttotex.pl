#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use File::Basename;

#################################################################
###########Global Variables#############
my $fi;
my $fo;
my $salto_pagina;
my $lineas_por_pagina;
my @texto_completo;
my @texto_en_palabras;
my $texto_size;
my $texto_nueva_linea = 20;
my $max_heigth = 3;
my $max_width = 100;
####### Read input arguments   #####
my $opt_help = undef;
my $texts_dir = undef;
my $output_dir = undef;
my $tex_name = undef;
my $no_correction = undef;
my $no_pdf = undef;
my $input_text = undef;
my @args = @ARGV;
GetOptions('help'=> \$opt_help,
            'no_correction=s'=> \$no_correction,
            'no_pdf'=> \$no_pdf,
            'texts_dir=s'=> \$texts_dir,
	         'input_text=s'=>\$input_text,
            'output_dir=s'=> \$output_dir,
            'tex_name=s'=>\$tex_name,
        );
#################################################################
##########        MAIN        ##########
&process_args();
&merge_pages();
&initialize_latex();
#&correction() if (!defined $no_correction);
&corregir();
&close_latex();

###################################################################
sub process_args(){
#Ayuda
	&print_help() if (defined $opt_help);
#Si no hay carpeta quÃ© procesar, salir con error.
	die("Se necesita una carpeta con imagenes para usar el programa o un archivo de texto con lo convertido.") if(!defined $texts_dir && !defined $input_text);
#Asignar la carpeta de salida en base a la de entrada si no se define
	#($output_dir = $texts_dir) =~ s/(.*)/$1_txttotex/ if (!defined $output_dir);
	$tex_name = "tex_file" if (!defined $tex_name);
	$tex_name .= ".tex";
}
sub merge_pages(){
   my $linea;
   `cat *.txt > mergedfile.temp` if(defined $texts_dir);

   open ($fi, "< :encoding(Latin1)", $input_text) or die "No se pudo abrir archivo: $input_text";
   open ($fo, '>', $tex_name) or die "No se pudo abrir archivo: $tex_name";
   while ($linea = <$fi>){
      push @texto_completo, $linea if ($linea !~ /^\s*$/);
   }
   foreach $linea (@texto_completo){
      $linea =~ s/\n//g;
      print "new_line found: $linea" if($linea =~ /\n/);
      $linea .= " <NUEVA_LINEA>" if ($texto_nueva_linea >= length $linea);
#chomp $linea;
      #if($linea !~ /Ë†\s*$/){
         push @texto_en_palabras, split / /, $linea;
      #}
   }
   $texto_size = @texto_en_palabras;
   #foreach my $palabra (@texto_en_palabras){
   #   print "--$palabra--";
   #}
}
sub initialize_latex(){
   print $fo "\\documentclass[12pt]{article}\n";
   print $fo "\\begin{document}\n";
   #&set_new_page();
}

sub corregir(){
   my $word_index = 0;
   my $word_beginning = 0;
   my $height_count = 1;
   my $width_count = 0;
   my $word_length;
   my $print_index;
   my $index = 0;
   my $real_length;
   my $word;
   while ($word_index < $texto_size){
      $word = $texto_en_palabras[$word_index];
      #print $word;
      if ($word eq "<NUEVA_LINEA>"){
         $word_index++;
         $width_count = 0;
         $height_count++;
         $width_count = $max_heigth+1 if ($height_count > $max_heigth);
         #print "found new line, new width_count: $width_count";
      }else{
         $index++;
         ($word,$real_length,$print_index) = &rellenar_espacios($word,$index);
         if ($width_count + $real_length +1> $max_width || ($word_index +1) eq $texto_size){
            #print "SI. $width_count+$real_length +1 > $max_width, $word,$word_index-1,$texto_size,$height_count,$max_heigth\n";
            if ($height_count + 1 > $max_heigth || ($word_index +1)eq $texto_size){
               $word_index++ if($word_index +1 eq $texto_size);
               &seleccion($word_beginning,$word_index-1);
               $height_count = 1;
               $width_count  = 0;
               $index = 0;
               $word_beginning = $word_index;
            }else{
               $word_index++;
               $width_count = $real_length;
               $height_count++;
            }
         }else{
            #print "NO: $width_count+$real_length +1 > $max_width, $word,$word_index-1,$height_count,$max_heigth\n";
            $width_count += $real_length +1;
            $word_index++;
         }
      }
   }
}
sub seleccion(){
   my $low_index  = $_[0];
   my $high_index = $_[1];
   my $opcion;
   &print_table($low_index,$high_index);
   print "Introduzca una opcion (1) o (2):\t";
   $opcion = <>;
   $opcion =~ s/\n//;
   print "opcion escogida: <$opcion>\n";
   ($low_index,$high_index) = &modificar($opcion,$low_index,$high_index);
   &seleccion($low_index,$high_index) if($opcion ne 0);

}
sub print_table(){
   my $low_index  = $_[0];
   my $high_index = $_[1];
   my $index = 1;
   my $palabra; my $real_length; my $print_index;
   my @numeros;
   my $width_count = 0;
   my $numero;
   while ($low_index <= $high_index){
      if ($texto_en_palabras[$low_index] ne "<NUEVA_LINEA>"){
         $palabra = $texto_en_palabras[$low_index];
         ($palabra,$real_length,$print_index) = &rellenar_espacios($palabra,$index++);
         if ($width_count + $real_length +1 > $max_width){
            print "\n";
            foreach $numero (@numeros){
               print RED, "$numero ", RESET;
            }
            print "\n\n";
            $width_count = 0;
            @numeros=($print_index);
         }else{
            push @numeros, $print_index;
         }
         print GREEN, "$palabra ", RESET;
         $width_count += $real_length +1;
      }else{
         print "\n";
         foreach $numero (@numeros){
            print RED, "$numero ", RESET;
         }
         print "\n\n";
         $width_count = 0;
         @numeros=();
      }
      $low_index++;
   }
   print "\n";
   foreach $numero (@numeros){
      print RED, "$numero ", RESET;
   }
   print "\n\n";
}
sub modificar(){
   my $comando    = $_[0];
   my $low_index  = $_[1];
   my $high_index = $_[2];
   my $local_index;
   my @cm   = split /\s+/, $comando;
   my @rango; my $fix;
   my $letra = shift @cm;
   my $pos; my $cm_length; my $menor; my $mayor; my $tipo;
   my $low_copy = $low_index;
   my @new_lines; my $new_line_count=0;
   while ($low_copy <= $high_index){
      #print "$texto_en_palabras[$low_copy]";
      #print "\n";
      if($texto_en_palabras[$low_copy] eq "<NUEVA_LINEA>"){
         #print "pushing: $low_copy\n";
         push @new_lines, $low_copy+$new_line_count;
         splice @texto_en_palabras, $low_copy, 1;
         #print "after pushing: $texto_en_palabras[$low_copy]\n";
         $new_line_count++;
      }else{
         $low_copy++;
      }
   }
   if ($letra eq "i"){
      $tipo = shift @cm;
      if ($tipo =~ /,/){
         push @rango, split /,/,$tipo;
         $local_index=0;
         foreach $pos (@rango){
            $texto_en_palabras[$low_index+$pos-1] = $cm[$local_index++];
         }
      }elsif($tipo =~ /-/){
         ($menor,$mayor) = split /-/,$tipo;
         $cm_length = @cm;
         splice @texto_en_palabras, $low_index+$menor-1, $mayor-$menor+1, @cm;
         $fix =  $cm_length - ($mayor - $menor + 1);
         $texto_size += $fix;
         $high_index += $fix;
      }else{
         $texto_en_palabras[$low_index+$tipo-1] = $cm[0];
         #print "$low_index,$tipo,$cm[0],$texto_en_palabras[$low_index+$tipo]\n";
      }
   }
   if ($tipo =~ /,/ || $tipo !~ /-/){
      foreach my $new_line (@new_lines){
         splice @texto_en_palabras, $new_line, 0, "<NUEVA_LINEA>";
      }
   }else{
      foreach my $new_line (@new_lines){
         if ($new_line <= $menor){
            splice @texto_en_palabras, $new_line, 0, "<NUEVA_LINEA>";
            $new_line_count++;
         }elsif($new_line > $mayor){
            #print "fix: $fix, menor: $menor, mayor: $mayor\n";
            splice @texto_en_palabras, $new_line+$fix, 0, "<NUEVA_LINEA>";
         }
      }
   }
   return ($low_index,$high_index);
}
sub rellenar_espacios(){
   my $palabra = $_[0];
   my $numero  = $_[1];
   $palabra = &rellenar(&log10($numero),$palabra);
   my $sum_ordd=0;
   my $odd_flag=0;
   my $ordd;
   for my $c (split //,$palabra){
      $ordd = ord($c);
      if ($ordd > 126){
         $sum_ordd++ if($odd_flag eq 1);
         $odd_flag=1;
      }
      else{
         $odd_flag=0; 
      }
   }
   my $palabra_length = length $palabra;
   $palabra_length -= $sum_ordd;
   $numero = &rellenar($palabra_length,$numero);
   my @result = ($palabra,$palabra_length,$numero);
   return @result;
}
sub rellenar(){
   my $espacio=$_[0];
   my $palabra=$_[1];

   my $palabra_length = length $palabra;
   return $palabra if($palabra_length>=$espacio);
   my $espacios = $espacio - $palabra_length;
   my $izq = int($espacios/2);
   my $zeros_izq = 0;
   while ($izq > 0){
      $palabra = " "."$palabra";
      $zeros_izq++;
      $izq--;
   }
   my $der = $espacios-$zeros_izq;
   while ($der > 0){
      $palabra = "$palabra"." ";
      $der--;
   } 
   return $palabra;
}
sub log10(){
   my $num=$_[0];
   my $log_10=1;
   $log_10++ while(10**$log_10<$num);
   return $log_10;
}

sub close_latex(){
   print $fo "\\close{document}\n";
}
sub generate_latex(){
   print "salto_pagina = $salto_pagina\n";
   print "lineas_por_pagina = $lineas_por_pagina\n";
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
    --output_dir <path> Path en donde se guardarÃ¡n las conversiones.
    --formats "txt,pdf" Formatos a usar. Uno o varios. Ejemplo: --formats txt.

    Por default --ocrs es t (Tesseract), --output_dir es <input_dir>_convertido, --formats es txt.
HELP
    print("\n$message\n") if (defined $message);
    exit 0;
}
sub set_new_page(){
   my $max_casos = 10;
   my $casos = 0;
   my $consecutiva = 0;
   my $saltos_seguidos = 0;
   my $lineas_seguidas = 0;
   my @valores; my @valores_lineas;
   my $item; my $total=0; my $total_lineas=0;
   my $fi_temp = $fi;
   NEW_PAGE: while (my $linea = <$fi_temp>){
      chomp $linea;
      #print "set_new_page: $linea";
      if ($linea =~ /^\s*$/){
	      #print "$linea->NEW_PAGE!\n";
         if ($consecutiva eq 0){
            push @valores_lineas, $lineas_seguidas;
	    $lineas_seguidas = 0;
            $consecutiva =1;
         }
	 $saltos_seguidos++;
      }else{
	      #print "->NO NEW_PAGE!\n";
         $lineas_seguidas++;
	 if ($consecutiva eq 1){
	    push @valores, $saltos_seguidos;
	    $saltos_seguidos = 0;
	    $casos++;
	    $consecutiva = 0;
	 }
      }
      last NEW_PAGE if ($casos >= $max_casos);
   }
   foreach $item (@valores){
      $total += $item;
   }
   foreach $item (@valores_lineas){
      $total_lineas += $item;
   }
   $salto_pagina = int($total/$casos);
   $lineas_por_pagina = int($total_lineas/$casos);
}

