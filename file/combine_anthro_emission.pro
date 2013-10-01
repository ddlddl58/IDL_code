pro combine_anthro_emission

   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau, CTM_WriteBpch

   CTM_CleanUp

   flag = 1

   InType   = CTM_Type( 'geos5', Res=[ 2.0d0/3.0d0, 0.5d0])
   InGrid   = CTM_Grid( InType, /No_Vertical )


   Year = 2006
   Yr4  = string( Year, format='(i4.4)' )
   NYMD0 = Year * 10000L + 1 * 100L + 1L
   tau0  = nymd2tau( NYMD0 )
   close, /all
  
   China_mask   = fltarr(InGrid.IMX, InGrid.JMX)
   temp_emis_1  = fltarr(InGrid.IMX, InGrid.JMX)
   temp_emis_2  = fltarr(InGrid.IMX, InGrid.JMX)
   combine_emis = fltarr(InGrid.IMX, InGrid.JMX)

   emisfile1 = '/public/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_res_2006.geos5.05x0666'
   emisfile2 = '/home/gengguannan/indir/intexb_scaled/NOx_res_2006.05x0666'
   maskfile  = '/public/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
   outfile   = '/home/gengguannan/indir/intexb_scaled/combine_NOx_res_2006.05x0666'

   Undefine, emis_1
   Undefine, emis_2
   Undefine, mask

   CTM_Get_Data, emis_1, 'ANTHSRCE', Tracer = 1, filename = emisfile1, Tau0 = tau0
   temp_emis_1[*,*] = *(emis_1[0].data)

   CTM_Get_Data, emis_2, 'ANTHSRCE', Tracer = 1, filename = emisfile2, Tau0 = tau0
   temp_emis_2[*,*] = *(emis_2[0].data)

   CTM_Get_Data, mask, 'LANDMAP', Tracer = 2, filename = maskfile, Tau0 = Nymd2Tau(19850101)
   China_mask[*,*] = *(mask[0].data)

   FOR I = 0,InGrid.IMX-1 do begin
     FOR J = 0,InGrid.JMX-1 do begin
       if China_mask[I,J] gt 0 $
         then combine_emis[I,J] = temp_emis_2[I,J] $
         else combine_emis[I,J] = temp_emis_1[I,J]
     ENDFOR
   ENDFOR
      
print,total(temp_emis_2),total(combine_emis)


   Success = CTM_Make_DataInfo( Float(combine_emis[*,*]),$
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='ANTHSRCE',        $
                                Tracer=1,                $
                                Tau0= tau0,              $
                                Unit='Kg/year',          $
                                Dim=[InGrid.IMX,         $
                                     InGrid.JMX, 0, 0],  $
                                First=[1L, 1L, 1L],      $
                                /No_Global )


     NewDataInfo = ThisDataInfo

     NewFileInfo = ThisFileInfo

     CTM_WriteBpch, NewDataInfo, NewFileInfo, FileName = outfile

End
