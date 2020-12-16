      subroutineopacity(rho,temp,abund,nfreqOpac,freq,freqmn,dvdr,linedatafile,rdlndump,mkshortlist,longlist,taumin,xsecdatadir,opac
     *,scatop,eden)
      usekinds,only:dp
      userad_photo_cross_section,only:photoCross
      implicitreal*8(a-h,o-z)
      integer,parameter::p_Nelements=99
      real*8,parameter::p_x_i_flo=1d-17
      integer,parameter::p_jmax=6
      integernfreqOpac
      character*(*)linedatafile,longlist,xsecdatadir
      logicalrdlndump,mkshortlist
      real*8rho,temp,abund(p_Nelements),freq(nfreqOpac+1),freqmn(nfreqOpac),taumin
      real*8opac(nfreqOpac),scatop(nfreqOpac)
      real*8iondenz(p_jmax,p_Nelements),iondenz_part(p_jmax,p_Nelements)
      real*8iondenzHminus
      integerionstg1(p_Nelements)
      real*8frac(0:31),part(0:31),nucden
      realtm1,tm2
      real*8expnu(nfreqOpac)
      real*8plnkfnc(nfreqOpac)
      real(kind=dp),dimension(nfreqOpac)::sigma
      parameter(maxfreqdim=5000)
      real*8wave(maxfreqdim+1)
      real*8hfreq3c2(maxfreqdim)
      real*8dlnfreq(maxfreqdim)
      real*8freqm3(maxfreqdim)
      real*8gff(nfreqOpac*30)
      PARAMETER(NVARS=3)
      include '../obj/nfreq_and_mzone.inc'
      PARAMETER(NYDIM=(NVARS+2*NFREQ)*Mzon,MAXDER=4)
      Parameter(Is=5)
      PARAMETER(NZ=3000000)
      Parameter(Nstage=28,Natom=15)
      PARAMETER(KOMAX=80)
      LogicalLSYSTEM
      Parameter(LSystem=.FALSE.)
      Parameter(Pi=3.1415926535897932d+00,hPlanc=1.0545716280D-27,Cs=2.9979245800D+10,Boltzk=1.3806504000D-16,Avogar=6.0221417900D+2
     *3,AMbrun=1.6605387832D-24,AMelec=9.1093821500D-28,echarg=4.8032042700D-10,CG=6.6742800000D-08,CMS=1.9884000000D+33,RSol=6.9551
     *000000D+10,ULGR=1.4000000000D+01,UPURS=1.0000000000D+07,ULGPU=7.0000000000D+00,ULGEU=1.3000000000D+01,UPC=3.0856776000D+18,UTP
     *=1.0000000000D+05,URHO=1.0000000000D-06,CARAD=7.5657680191D-15,CSIGM=5.6704004778D-05,ERGEV=1.6021764864D-12,GRADeV=1.16045052
     *85D+04,RADC=7.5657680191D-02,CTOMP=4.0062048575D-01,CCAPS=2.6901213726D+01,CCAPZ=9.8964034725D+00)
      IntegerZn(Natom),ZnCo(Natom+1)
      DimensionAZ(Natom)
      Common/AZZn/AZ,Zn,ZnCo
      saveptrplnkfnc,ptrexpnu,ptrwave,ptrhfreq3c2
      saveptrdlnfreq,ptrgff,ptrfreqm3,ptrsigma
      saveinit,lopinit
      savedlnfreq,wave,hfreq3c2,freqm3
      parameter(twopi=2.d0*pi,fourpi=2.d0*pi)
      parameter(epsT=1.d-3)
      parameter(c=Cs,h=twopi*hPlanc,evtoerg=ERGEV,bc=Boltzk,elecxsec=CTOMP/Avogar,a=CARAD,stefbltz=CSIGM)
      datahmass/1.67352d-24/
      parameter(esu=echarg,emass=AMelec)
      datasrpi/1.772453851d+00/,bcev/8.617064d-05/
      datainit/1/,ffop0/3.6914403278312d+08/,mode/2/
      datarydnu/3.2880513d+15/,n_hyd_max/9/,lopinit/0/
      donf=1,nfreqOpac
      wave(nf)=c*1.d+08/freq(nf)
      hfreq3c2(nf)=h*freqmn(nf)**3/c**2
      freqm3(nf)=freqmn(nf)**(-3)
      enddo
      wave(nfreqOpac+1)=c*1.d+08/freq(nfreqOpac+1)
      donf=1,nfreqOpac
      dlnfreq(nf)=dlog(freq(nf+1)/freq(nf))
      enddo
      init=0
      bct=bc*temp
      donf=1,nfreqOpac
      expnu(nf)=dexp(-h*freqmn(nf)/bct)
      plnkfnc(nf)=hfreq3c2(nf)*expnu(nf)/(1.d+00-expnu(nf))
      enddo
      nucden=abund(1)*rho/hmass
      doiz=2,p_Nelements
      nucden=nucden+abund(iz)*rho/(dble(2*iz)*hmass)
      enddo
      maxiter=30
      acc=1.d-03
      numelems=p_Nelements
      calledensol(rho,temp,abund,eden,maxiter,acc,numelems)
      	if(eden.ne.eden)print*,' Bardak:',abund
3     format(' rho: ',1pe10.3,' temp: ',1pe10.3,' eden / nucden: ',1pe10.3)
      press=bct*(eden+nucden)
      doiz=1,p_Nelements
      if(iz.eq.1)then
      totden=abund(iz)*rho/hmass
      else
      totden=abund(iz)*rho/(dble(2*iz)*hmass)
      endif
      if(abund(iz).gt.0.d+00)then
      callsahaeqn(1,.true.,press,temp,eden,iz,6,ionstg1(iz),frac,part)
      if(iz.eq.1)iondenzHminus=totden*frac(0)
      doi=1,min(6,iz+1)
      iondenz(i,iz)=totden*frac(i)
      	iondenz_part(i,iz)=iondenz(i,iz)/part(i)
      enddo
      else
      doi=1,min(6,iz+1)
      iondenz(i,iz)=0.d0
      	iondenz_part(i,iz)=0.d0
      enddo
      endif
      enddo
      donf=1,nfreqOpac
      scatop(nf)=eden*elecxsec
      opac(nf)=0.d+00
      enddo
      calllineexpop(linedatafile,rdlndump,nfreqOpac,nfreqOpac,hfreq3c2,dlnfreq,wave,scatop,opac,dummy,plnkfnc,lopinit,mkshortlist,ta
     *umin,longlist,1,1,eden,temp,dvdr,iondenz_part,ionstg1,1,1)
      callgffcalc(gff,temp,freqmn,nfreqOpac,nfreqOpac,30)
      ffgcoeff=ffop0*eden/sqrt(temp)
      doiz=1,p_Nelements
      if(abund(iz).gt.0.d+00)then
      i1=ionstg1(iz)
      dok=1,min(6,iz+1)
      i=k+ionstg1(iz)-1
      ieff=i-1
      z2=dble(ieff)**2
      if(ieff.gt.0)then
      donf=1,nfreqOpac
      opterm=ffgcoeff*freqm3(nf)
      ffop=iondenz(k,iz)*opterm*z2*gff(nf+(ieff-1)*nfreqOpac)
      opac(nf)=opac(nf)+ffop*(1.d+00-expnu(nf))
      enddo
      endif
      enddo
      endif
      enddo
      doiz=1,p_Nelements
      if(abund(iz).gt.0.d+00)then
      i1=ionstg1(iz)
      dok=1,min(6,iz)
      i=ionstg1(iz)+k-1
      ne=iz-i+1
      if(ne.gt.1)then
      callvalence_nl(iz,i,n_princ,l_ang)
      if((n_princ.lt.4).or.((n_princ.eq.4).and.(l_ang.eq.0)))then
      callgshfdxsec(iz,ne,n_princ,l_ang,nfreqOpac,xsecdatadir,mode,freqmn,e_thresh,sigma)
      donf=1,nfreqOpac
      opac(nf)=opac(nf)+iondenz_part(k,iz)*sigma(nf)*dble(2*l_ang+1)*(1.d+00-expnu(nf))
      enddo
      endif
      elseif(ne.eq.1)then
      if(iz.EQ.1)then
      donf=1,nfreqOpac
      CallhMinusAbsorp(temp,wave(nf)/1.d4,4,sig)
      opac(nf)=opac(nf)+iondenzHminus*sig*(1.d+00-expnu(nf))
      enddo
      endif
      freq0=rydnu*dble(iz**2)
      don_princ=1,n_hyd_max
      freqn=rydnu*dble(iz**2)/dble(n_princ)**2
      if(freqn.lt.freq(nfreqOpac))then
      expfac=2.d+00*dble(n_princ**2)*exp(-h*(freq0-freqn)/bct)
      donf=1,nfreqOpac
      phot=freqmn(nf)/freqn
      if(phot.ge.1.d+00)then
      eps=sqrt(phot-1.d+00)+1.d-06
      sig=6.3d-18*(exp(4.d0*(1.d0-atan(eps)/eps))/(1.d0-exp(-twopi/eps)))/(phot**4*dble(iz**2))
      opac(nf)=opac(nf)+iondenz_part(k,iz)*expfac*sig*(1.d+00-expnu(nf))
      endif
      enddo
      endif
      enddo
      endif
      enddo
      endif
      enddo
      return
      end
