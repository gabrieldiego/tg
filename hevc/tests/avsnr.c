/************************************************************************ 
* 
*  avsnr.c 
* 
*  Telenor Broadband Services  
*  Keysers gate 13                         
*  N-0130 Oslo 
*  Norway                   
* 
************************************************************************/ 
// Source: http://read.pudn.com/downloads101/sourcecode/multimedia/412227/avsnr.c__.htm
#include <string.h> 
#include <stdio.h> 
#include <math.h> 
#include <stdlib.h> 

#define max( a, b ) ( ( ( a > b) ? a : b ) )
#define min( a, b ) ( ( ( a < b) ? a : b ) )

void main(int argc,char **argv) 
{ 
  FILE *fd; 
  FILE *p_log; 
  char snr_filename[100]; 
  float tmp; 
   
  double xl,xh;// end points 
  double diff; 
  int mode;    // dsnr or percentage mode 
  
 
  int J0=0;//SNR index 
  int J1=1;//bitrate index 
 
  double X[2][4]; 
    
  double Y[2][4]; 
   
  double E[4],F[4],G[4],H[4]; 
  double SUM[2]; 
   
  int ind[2]; 
  int i,j; 
   
  double  DET0,DET1,DET2,DET3,DET; 
  double  D0,D1,D2,D3; 
  double  A,B,C,D; 
 
  if (argc != 2)  
  { 
    printf("Usage: %s <snr.txt> \n",argv[0]); 
    printf("<snr.txt> gives snr values and bitrates\n"); 
    printf("Format:\n"); 
    printf("snrA0  snrA1  snrA2  snrA3 \n"); 
    printf("birtA0 bitrA1 bitrA2 bitrA3 \n"); 
    printf("snrB0  snrB1  snrB2  snrB3 \n"); 
    printf("birtB0 bitrB1 bitrB2 bitrB3 \n"); 
 
 
    exit(-1); 
  } 
  strcpy(snr_filename,argv[1]); 
   
  if((fd=fopen(snr_filename,"r")) == NULL){ 
      printf("Error: Input file %s not found\n",snr_filename); 
      exit(0); 
  }  
  else{   
    printf("--------------------------------------------------------------------------\n"); 
    printf(" SNR input file               : %s \n",snr_filename); 
    printf("--------------------------------------------------------------------------\n"); 
    printf(" Computing average differance of 2 datasets \n"); 
    
  } 
   
  fscanf(fd,"%d",&mode);      // read mode 0=DSNR 1=Percentage 
  fscanf(fd,"%*[^\n]");         // new line  
 
   
  for(i=0;i<4;i++){ 
    fscanf(fd,"%f",&tmp);      // first 4 SNR values 
    if(mode==0) 
      Y[0][i]=tmp; 
    else 
      X[0][i]=tmp; 
    } 
  fscanf(fd,"%*[^\n]");         // new line  
   
  for(i=0;i<4;i++){             // first 4 bitrate values 
    fscanf(fd,"%f,",&tmp); 
    if(mode==0) 
      X[0][i]=log(tmp); 
    else 
      Y[0][i]=log(tmp); 
  } 
  fscanf(fd,"%*[^\n]");   
 
  for(i=0;i<4;i++){ 
    fscanf(fd,"%f,",&tmp); 
    if(mode==0) 
      Y[1][i]=tmp; 
    else 
      X[1][i]=tmp; 
 
  } 
  fscanf(fd,"%*[^\n]"); 
   
  for(i=0;i<4;i++){ 
    fscanf(fd,"%f,",&tmp); 
    if(mode==0) 
      X[1][i]=log(tmp); 
    else 
      Y[1][i]=log(tmp); 
  } 
  fscanf(fd,"%*[^\n]");   
 
 
  xl=max(X[J0][0],X[J1][0]); 
  xh=min(X[J0][3],X[J1][3]); 
  ind[0]=J0; 
  ind[1]=J1; 
   
   
  for (j=0;j<2;j++){ 
    for (i=0;i<4;i++){       
      E[i]=X[ind[j]][i];             
      F[i]=E[i]*E[i];          
      
      G[i]=E[i]*E[i]*E[i]; 
      H[i]=Y[ind[j]][i]; 
    } 
 
    DET0= E[1]*(F[2]*G[3]-F[3]*G[2])-E[2]*(F[1]*G[3]-F[3]*G[1])+E[3]*(F[1]*G[2]-F[2]*G[1]); 
    DET1=-E[0]*(F[2]*G[3]-F[3]*G[2])+E[2]*(F[0]*G[3]-F[3]*G[0])-E[3]*(F[0]*G[2]-F[2]*G[0]); 
    DET2= E[0]*(F[1]*G[3]-F[3]*G[1])-E[1]*(F[0]*G[3]-F[3]*G[0])+E[3]*(F[0]*G[1]-F[1]*G[0]); 
    DET3=-E[0]*(F[1]*G[2]-F[2]*G[1])+E[1]*(F[0]*G[2]-F[2]*G[0])-E[2]*(F[0]*G[1]-F[1]*G[0]); 
    DET=DET0+DET1+DET2+DET3; 
 
      
    D0=H[0]*DET0+H[1]*DET1+H[2]*DET2+H[3]*DET3; 
     
     
    D1= 
      H[1]*(F[2]*G[3]-F[3]*G[2])-H[2]*(F[1]*G[3]-F[3]*G[1])+H[3]*(F[1]*G[2]-F[2]*G[1])- 
      H[0]*(F[2]*G[3]-F[3]*G[2])+H[2]*(F[0]*G[3]-F[3]*G[0])-H[3]*(F[0]*G[2]-F[2]*G[0])+ 
      H[0]*(F[1]*G[3]-F[3]*G[1])-H[1]*(F[0]*G[3]-F[3]*G[0])+H[3]*(F[0]*G[1]-F[1]*G[0])- 
      H[0]*(F[1]*G[2]-F[2]*G[1])+H[1]*(F[0]*G[2]-F[2]*G[0])-H[2]*(F[0]*G[1]-F[1]*G[0]); 
  
    D2= 
      E[1]*(H[2]*G[3]-H[3]*G[2])-E[2]*(H[1]*G[3]-H[3]*G[1])+E[3]*(H[1]*G[2]-H[2]*G[1])- 
      E[0]*(H[2]*G[3]-H[3]*G[2])+E[2]*(H[0]*G[3]-H[3]*G[0])-E[3]*(H[0]*G[2]-H[2]*G[0])+ 
      E[0]*(H[1]*G[3]-H[3]*G[1])-E[1]*(H[0]*G[3]-H[3]*G[0])+E[3]*(H[0]*G[1]-H[1]*G[0])- 
      E[0]*(H[1]*G[2]-H[2]*G[1])+E[1]*(H[0]*G[2]-H[2]*G[0])-E[2]*(H[0]*G[1]-H[1]*G[0]); 
    
    D3= 
      E[1]*(F[2]*H[3]-F[3]*H[2])-E[2]*(F[1]*H[3]-F[3]*H[1])+E[3]*(F[1]*H[2]-F[2]*H[1])- 
      E[0]*(F[2]*H[3]-F[3]*H[2])+E[2]*(F[0]*H[3]-F[3]*H[0])-E[3]*(F[0]*H[2]-F[2]*H[0])+ 
      E[0]*(F[1]*H[3]-F[3]*H[1])-E[1]*(F[0]*H[3]-F[3]*H[0])+E[3]*(F[0]*H[1]-F[1]*H[0])- 
      E[0]*(F[1]*H[2]-F[2]*H[1])+E[1]*(F[0]*H[2]-F[2]*H[0])-E[2]*(F[0]*H[1]-F[1]*H[0]); 
    
 
    A=D0/DET; 
    B=D1/DET; 
    C=D2/DET; 
    D=D3/DET; 
    
    
    SUM[j]=A*(xh-xl)+B*(xh*xh-xl*xl)/2+C*(xh*xh*xh-xl*xl*xl)/3+D*(xh*xh*xh*xh-xl*xl*xl*xl)/4; 
     
  }  
   
  diff=(SUM[1]-SUM[0])/(xh-xl); 
   
  if(mode==1)  //Percentage 
     diff=(exp(diff)-1)*100; 
   
  if (mode==0) 
  { 
    printf(" Logaritmic mode \n"); 
    printf(" Areal of integrated area()  = %f\n",diff); 
  } 
  else 
  { 
    printf(" Percentage mode \n"); 
    printf(" Percentage difference between the courves are = %f\n",diff); 
  } 
   
  /* 
  write to log file 
  */ 
  printf(" Write to 'log.dat' \n");  
  if (fopen("log.dat","r")==0)                      /* check if file exist */ 
  { 
    if ((p_log=fopen("log.dat","a"))==0)            /* append new statistic at the end */ 
    { 
      printf("Error open file %s  \n",p_log); 
      exit(0); 
    } 
    else                                            /* Create header for new log file */ 
    { 
      fprintf(p_log," --------------------------------------------------------------------------------------------------------------------------------------- \n"); 
      fprintf(p_log,"|   Log file for  'avsnr'. This file is generated during first encoding session, new sessions will be appended                           |\n");   
      fprintf(p_log," --------------------------------------------------------------------------------------------------------------------------------------- \n"); 
      fprintf(p_log,"|SNR a0|SNR a1|SNR a2|SNR a3|Bit a0|Bit a1|Bit a2|Bit a3|SNR b0|SNR b1|SNR b2|SNR b3|Bit b0|Bit b1|Bit b2|Bit b3|   Mode      | Output  |\n"); 
      fprintf(p_log," --------------------------------------------------------------------------------------------------------------------------------------- \n"); 
    } 
  } 
  else  
    p_log=fopen("log.dat","a");                     /* File exist,just open for appending */                       
   
  fprintf(p_log,"|"); 
  if (mode==0){ 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",Y[0][i]); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",exp(X[0][i])); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",Y[1][i]); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",exp(X[1][i])); 
 
     fprintf(p_log,"  DSNR mode  |",mode); 
     fprintf(p_log,"%6.3f dB|\n",diff); 
  } 
  else{ 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",X[0][i]); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",exp(Y[0][i])); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",X[1][i]); 
    for (i=0;i<4;i++) 
      fprintf(p_log,"%6.2f|",exp(Y[1][i])); 
 
 
     fprintf(p_log," Percent mode|"); 
     fprintf(p_log,"%8.2f%% %%|\n",diff); 
  } 
   
   
  printf(" AvSNR version 4 \n");  
 
} 
 
