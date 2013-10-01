pro ts_sep

year = 2007
month = 10
for day = 1,31 do begin

Yr4 = String( year, format = '(i4.4)' )
Mon2 = String( month, format = '(i2.2)' )
Day2 = String( day, format = '(i2.2)' )

NYMD = year * 10000L + month * 100L + day * 1L
print, NYMD
tau0 = nymd2tau(NYMD)

date = month * 100L + day * 1L
if date eq 0229 then continue
if date eq 0230 then continue
if date eq 0231 then continue
if date eq 0431 then continue
if date eq 0631 then continue
if date eq 0931 then continue
if date eq 1131 then continue


; The big input file
Infile = '/z1/gengguannan/meic_120918/'+ Yr4 +'/ts.'+ Yr4 + Mon2 + Day2 +'.bpch'

; Split the data in the big file into a separate file
Outfile = '/home/gengguannan/GC_output/meic_120918/'+ Yr4 +'/ts.'+ Yr4 + Mon2 + Day2 +'.bpch'

tau1 = tau0 + 8
tau2 = tau0 + 9
tau3 = tau0 + 10
tau4 = tau0 + 11
tau5 = tau0 + 12
tau6 = tau0 + 13
tau7 = tau0 + 14
tau8 = tau0 + 15
tau9 = tau0 + 16
tau10 = tau0 + 17

bpch_sep, InFile, Outfile, tau0=[tau1,tau2,tau3,tau4,tau5,tau6,tau7,tau8,tau9,tau10]
ctm_cleanup


endfor

end
