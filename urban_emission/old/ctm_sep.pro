pro ctm_sep

year = 2008
Yr4 = String( year, format = '(i4.4)' )

for month = 1,12 do begin
Mon2 = String( month, format = '(i2.2)' )

nymd = 10000L*year + 100L*month + 1L*1
print,nymd

; The big input file
;Infile = '/z1/gengguannan/meic_120918/'+ Yr4 +'/ctm.'+ Yr4 +'1101.bpch'
Infile = '/z1/gengguannan/meic_120918/2007/ctm.20071101.bpch'
ctm_cleanup

; Split the data in the big file into a separate file
Outfile = '/z1/gengguannan/meic_120918/'+ Yr4 +'/ctm.'+ Yr4 + Mon2 +'.bpch'

bpch_sep, InFile, Outfile, tau=nymd2tau( nymd )


endfor

end
