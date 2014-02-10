package OP::GOPS::KW;

use strict;
use warnings;

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw();

###__ACCESSORS_HASH
our @hash_accessors=qw(
	accessors
	files
	vars
	chvars
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	keywords
	false
	true
	shiftvars
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub init_vars(){
	my $self=shift;

	$self->vars(qw());

}

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();
}

sub run() {
	my $self=shift;
	
	$self->read_const();
	$self->read_all_vars();
	$self->read_TF();
	$self->read_init_vars();
	$self->read_input();

	$self->final();

}

sub main() {
    my $self = shift;

    $self->get_opt();

    $self->init_vars();

    $self->run();

}


sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# read_input(){{{ 

sub read_input(){
	my $self=shift;

	my(@F,$kw,$iskw);
	
	$self->IFILE($self->_opt_get("i"));

	$self->say("Program name: " . $self->PROGNAME );
	$self->say("Input data file: " . $self->IFILE );
	
	open(F,"<",$self->IFILE ) || die $!;

	$self->out("Perl setvars-file is:\n");
	$self->out("	" . $self->files("setvars") . "\n");

	open(SV,">", $self->files("setvars")) || die $!;
	
	while(<F>){
		chomp; next if ( /^\s\*#/ || /^\s\*$/ );
		@F=split(' ',$_);
		$kw=uc shift @F;
		$iskw=1;

	#         ! loop over the rest of keywords {{{
	#         ! <kwd>
	# !
	# !  Enforce flatland.
	# !
	# 
	if($kw eq "2D" ){
		$self->vars("TWOD" => 1);
	# !
	# !  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	# !
	# !  bs360: ACE is to be used together with CHARMM and the ACE solvent model,
	# !  it makes sure that the Born radii are regularly updated
	# !
	# 
	}
	elsif($kw eq "ACE" ){
		$self->vars("ACESOLV" => 1);
	# !
	# !  Adjust NEB force constant values between different images on-the-fly in order
	# !  to try and equispace them.
	# !
	# 
		$self->shiftvars(qw( ACEUPSTEP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ACE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ADJUSTK" ){
	# !
	# !  ADM [OFF | ON n] prints the atomic distance matrix every n
	# !                   if switched on                 cycles       - default n=20
	# !
	# 
		$self->shiftvars(qw( KADJUSTFRQ KADJUSTTOL KADJUSTFRAC ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ADJUSTK => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ADM" ){
		$self->vars("ADMT" => 1);
	# !
	# !  Ackland embedded atom metal potentials.
	# !
	# 
		$self->shiftvars(qw( NADM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ADM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ACKLAND" ){
	#          CALL READI(ACKLANDID) ! default is 5 = Fe
	# 
	# !  Keywork ALPHA enables exponent values to be set for the averaged
	# !  Gaussian and Morse potentials. All defaults = 6.
	# !
	# 
	}
	elsif($kw eq "ALPHA" ){
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
	# !
	# ! SAT: ALLPOINTS turns on printing of coordinates to file points for intermediate steps.
	# ! This is the default.
	# !
	# 
		$self->shiftvars(qw( GALPHA MALPHA1 MALPHA2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ALPHA => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ALLPOINTS" ){
		$self->vars("PRINTPTS" => 1);
	# !
	# !  AMBER stuff
	# !
	# 
	}
	elsif($kw eq "AMBER" ){
		$self->vars("AMBER" => 1);
	#          CALL APARAMS
	#          CALL AREAD
	#          NATOMS=ATOMS
	#          DO J1=1,NATOMS
	#             Q(3*(J1-1)+1)=x(J1)
	#             Q(3*(J1-1)+2)=y(J1)
	#             Q(3*(J1-1)+3)=z(J1)
	#          ENDDO
	#          t=0
	#          ang=0
	#          imp=0
	#          count=0
	# ! MCP
	# 
	}
	elsif($kw eq "AMH" ){
		print "USING AMH ENERGIES FORCES\n";
		print "CALCULATE ENERGY AND FORCE TABLES  \n";
		$self->vars("AMHT" => 1);
		print "AMH FLAG \n";
		print "AMH NATOMS \n";
	#          IF (DEBUG) WRITE(6,*)'Entering WALESAMH_INITIAL'
	#          CALL WALESAMH_INITIAL
	#          IF (DEBUG)WRITE(6,*)'Leaving WALESAMH_INITIAL'
	#          IF (DEBUG)WRITE(6,*)'TARFL ',TARFL
	#            OPEN(30,FILE='proteins/'//TARFL,STATUS='OLD')
	#            READ(30,*)
	#            READ(30,*)NRES_AMH
	#            IF (NRES_AMH.GT.500) THEN
		print "FAILURE NRES_AMH GR THAN 500 CONNECTODATA\n";
	#               STOP
	#            ENDIF
	#            READ (30,25)(SEQ(I_RES),I_RES=1,NRES_AMH)
	# 25         FORMAT(25(I2,1X))
	#            CLOSE(30)
		print "NRES \n";
	#            NRES_AMH_TEMP=NRES_AMH
	#          DO J1=1,NRES_AMH
	#              Q(9*(J1-1)+1)=X_MCP(9*(J1-1)+1)
	#              Q(9*(J1-1)+2)=X_MCP(9*(J1-1)+2)
	#              Q(9*(J1-1)+3)=X_MCP(9*(J1-1)+3)
	#              Q(9*(J1-1)+4)=X_MCP(9*(J1-1)+4)
	#              Q(9*(J1-1)+5)=X_MCP(9*(J1-1)+5)
	#              Q(9*(J1-1)+6)=X_MCP(9*(J1-1)+6)
	#              Q(9*(J1-1)+7)=X_MCP(9*(J1-1)+7)
	#              Q(9*(J1-1)+8)=X_MCP(9*(J1-1)+8)
	#              Q(9*(J1-1)+9)=X_MCP(9*(J1-1)+9)
	#          ENDDO
	#          t=0
	#          ang=0
	#          imp=0
	#          count=0
	# !
	# ! sf344> start of AMBER-related keywords
	# !
	# 
	}
	elsif($kw eq "AMBER9" ){
		$self->vars("AMBERT" => 1);
	# !
	# ! csw34> if FREEZERES specified, populate the FROZEN array with A9RESTOATOM
	# !
	# 
	#         IF (FREEZERES) CALL A9RESTOATOM(FROZENRES,FROZEN,NFREEZE)
	#         IF ((PERMDIST.OR.LOCALPERMDIST).AND.(NPERMSIZE(1).EQ.NATOMS)) THEN
	#            PRINT '(A)','keyword> ERROR - PERMDIST or LOCALPERMDIST is specfied for AMBER, but there is no perm.allow file present'
	#            STOP
	#         ENDIF
	#         IF (FREEZEGROUPT) THEN
	# ! Write a list of FROZEN atoms for use in an (o)data file
	# 
	#            OPEN(UNIT=4431,FILE='frozen.dat',STATUS='UNKNOWN',FORM='FORMATTED')
	#            DO J1=1,NATOMS
	# !
	# ! Work out the distance from GROUPCENTRE to the current atom J1
	# !
	# 
	#               DISTGROUPX2=(COORDS1(3*GROUPCENTRE-2)-COORDS1(3*J1-2))**2
	#               DISTGROUPY2=(COORDS1(3*GROUPCENTRE-1)-COORDS1(3*J1-1))**2
	#               DISTGROUPZ2=(COORDS1(3*GROUPCENTRE  )-COORDS1(3*J1  ))**2
	#               DISTGROUPCENTRE=SQRT(DISTGROUPX2+DISTGROUPY2+DISTGROUPZ2)
	# ! If working in GT mode (default), FREEZE all atoms >GROUPRADIUS from the GROUPCENTRE atom
	# 
	#               IF((FREEZEGROUPTYPE=="GT").AND.(DISTGROUPCENTRE.GT.GROUPRADIUS)) THEN
	#                  NFREEZE=NFREEZE+1
	#                  FROZEN(J1)=.TRUE.
	#                  WRITE(4431,'(A,I6)') 'FREEZE ',J1
	# ! IF working in LT mode, FREEZE all atoms <GROUPRADIUS from the GROUPCENTRE atom
	# 
	#               ELSE IF((FREEZEGROUPTYPE=="LT").AND.(DISTGROUPCENTRE.LT.GROUPRADIUS)) THEN
	#                  NFREEZE=NFREEZE+1
	#                  FROZEN(J1)=.TRUE.
	#                  WRITE(4431,'(A,I6)') 'FREEZE ',J1
	#               END IF
	#            END DO
	#            CLOSE(4431)
	#         ENDIF
	# !
	# ! csw34> A copy of the FROZEN array called FROZENAMBER is created to be passed through to AMBERINTERFACE
	# !
	# 
	#         ALLOCATE(FROZENAMBER(NATOMS))
	#         FROZENAMBER(:)=FROZEN(:)
	#         IF(.NOT.ALLOCATED(ATMASS)) ALLOCATE(ATMASS(NATOMS))
	#         ATMASS(1:NATOMS) = ATMASS1(1:NATOMS)
	#         DO i=1,3*NATOMS
	#                 Q(i) = COORDS1(i)
	#         END DO
	# ! save atom names in array zsym
	# 
	#         do i=1,natoms
	#                 zsym(i) = ih(m04+i-1)
	#         end do
	#         RETURN
	# ! initialise unit numbers
	# 
	#         ambpdb_unit=1110
	#         ambrst_unit=1111
	#         mdinfo_unit=1112
	#         mdcrd_unit =1113
	}
	elsif($kw eq "AMBERIC" ){
	#         PRINT*, "amberic"
		$self->vars("AMBERICT" => 1);
	#         IF (NARGS .GT. 1) THEN
	#            IF (WORD2.EQ.'BACKBONE')  THEN
	#               PRINT*, "backbone interpolated"
		$self->vars("AMBIT" => 1);
	#            ELSE
	#               PRINT*, "keyword error in amberic"
	#               RETURN
	#            ENDIF
	#         ENDIF
		$self->shiftvars(qw( WORD2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( AMBERIC => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "AMBERSTEP" ){
	#         PRINT*, "amberstept"
		$self->vars("AMBSTEPT" => 1);
	}
	elsif($kw eq "AMBPERTOLD" ){
	#         PRINT*, "original perturbation scheme"
		$self->vars("AMBOLDPERTT" => 1);
	}
	elsif($kw eq "AMBPERTONLY" ){
		$self->vars("AMBPERTT" => 1);
	#         PRINT*, "amber pertonly, perthresh", perthresh
		$self->shiftvars(qw( PERTHRESH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( AMBPERTONLY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "AMBICDNEB" ){
		$self->vars("AMBICDNEBT" => 1);
	}
	elsif($kw eq "NAB" ){
	#         IF (FREEZERES) CALL A9RESTOATOM(FROZENRES,FROZEN,NFREEZE)
		$self->vars("NABT" => 1);
	#         DO i=1,3*NATOMS
	#                 Q(i) = COORDS1(i)
	#         END DO
	# ! save atom names in array zsym
	# 
	#         do i=1,natoms
	#                 zsym(i) = ih(m04+i-1)
	#         end do
	#         IF(.NOT.ALLOCATED(ATMASS)) ALLOCATE(ATMASS(NATOMS))
	# ! for the NAB interface, ATMASS is also set up in mme2wrapper, and that setting
	# ! overrides the one from below. However, both originate from the same prmtop file,
	# ! so they should be the same. ATMASS is being assigned here so that it's somewhat consistent
	# ! with the AMBER interface.
	# 
	#         ATMASS(1:NATOMS) = ATMASS1(1:NATOMS)
	#         WRITE(prmtop,'(A)') 'coords.prmtop'
	#         igbnab=igb
	#         if(igb==6) igbnab=0     ! this is also in vacuo, but NAB doesn't understand igb=6!
	#         CALL MMEINITWRAPPER(trim(adjustl(prmtop)),igbnab,saltcon,rgbmax,sqrt(cut))
	#         RETURN
	}
	elsif($kw eq "DF1" ){
		$self->vars("DF1T" => 1);
	}
	elsif($kw eq "DUMPSTRUCTURES" ){
		$self->vars("DUMPSTRUCTURES" => 1);
	#         WRITE(*,'(A)') ' keywords> Final structures will be dumped in different formats (.rst, .xyz, .pdb)'
	# !
	# ! Distinguish between old C of M/Euler and new angle/axis coordinates for
	# ! rigid body TIP potentials
	# !
	# 
	}
	elsif($kw eq "ANGLEAXIS" ){
		$self->vars("ANGLEAXIS" => 1);
	# !
	# !  Growing string arc tolerance.
	# !
	# 
	}
	elsif($kw eq "ARCTOL" ){
	# !
	# !  Specifies the highest symmetry axis to search for in routine {\bf symmetry}; default is six.
	# !
	# 
		$self->shiftvars(qw( ARCTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ARCTOL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "AXIS" ){
	# !
	# !  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
	# 
		$self->shiftvars(qw( NHCHECK ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( AXIS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BBCART" ){
	#          BBCART = .TRUE. ! use cartesians for backbone
	}
	elsif($kw eq "BBRSDM" ){
	# !
	# !  BBSDM minimiser.
	# !
	# 
		$self->vars("BBRSDMT" => 1);
		$self->shiftvars(qw( BBRGAM BBREPS BBRSIGMA1 BBRSIGMA2 BBRM BBRALPHA BBRCONV BBRSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BBRSDM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSCONV" ){
	# !
	# !  Turn on LBFGS gradient minimization. GMAX is the convergence
	# !  criterion for the RMS gradient, default 0.001.
	# !  For BFGSTS NEVL and NEVS are the maximum iterations allowed in the searches for
	# !  the largest and smallest eigenvectors, respectively and NBFGSMAX1 is the largest
	# !  number of BFGS steps allowed in the subsequent restricted minimization.
	# !  If the negative eigenvalue appears to have converged then NBFGSMAX2 steps
	# !  are allowed in the tangent space.
	# !  CONVU is used to determine convergence in such runs and BFGSCONV can be used
	# !  to set GMAX, the convergence criteria for the subspace optimization.
	# !
	# !  IF REOPT is true the smallest Hessian eigenvector is redetermined after the
	# !  EF step before the tangent space minimisation.
	# !
	# 
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
		$self->shiftvars(qw( GMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSCONV => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSMIN" ){
	# !
	# !  instructs the program to perform an LBFGS minimisation.
	# !  {\it gmax\/} is the convergence criterion
	# !  for the root-mean-square gradient, default $0.001$.
	# !
	# 
		$self->vars("BFGSMINT" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
		$self->shiftvars(qw( GMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSMIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSSTEP" ){
	# !
	# !  If starting from a transition state we just want to take one EF step using
	# !  BFGSTS before calling MYLBFGS (or something else).
	# !
	# 
		$self->vars("BFGSSTEP" => 1);
		$self->vars("BFGSTST" => 1);
		$self->shiftvars(qw( PUSHOFF ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSSTEP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSSTEPS" ){
	# !
	# !  BFGSSTEPS n sets the number of BFGS optimisation steps to perform
	# !          per call to OPTIM                                    - default n=1
	# !  If BFGSSTEPS is not specified then it is set to the same value as NSTEPS
	# !
	# 
	#         IF (NSTEPS.EQ.1) NSTEPS=BFGSSTEPS
		$self->shiftvars(qw( BFGSSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSSTEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSTS" ){
	# !
	# !  Hybrid BFGS/eigenvector-following transition state search.
	# !
	# 
		$self->vars("BFGSTST" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
	#          IF (NARGS.GT.4) THEN
	#          ENDIF
	#          IF (NARGS.GT.5) THEN
	#          ENDIF
		$self->vars("BFGSTST" => 1);
	# !
	# !  Tolerance for eigenvector overlap in BFGSTS where the number of tangent space
	# !  steps switches from small to large. 0.0001 was the traditional value (default).
	# !
	# 
		$self->shiftvars(qw( NEVS NBFGSMAX1 NBFGSMAX2 CEIG NEVL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BFGSTSTOL" ){
	# !
	# !  Debug for basin-hopping interpolation
	# !
	# 
		$self->shiftvars(qw( BFGSTSTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BFGSTSTOL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BHDEBUG" ){
		$self->vars("BHDEBUG" => 1);
	# !
	# !  Parameters for basin-hopping interpolation
	# !
	# 
	}
	elsif($kw eq "BHINTERP" ){
		$self->vars("BHINTERPT" => 1);
	# !
	# !  Additional parameter for basin-hopping interpolation.
	# !  Save the lowest energy minimum, rather than the lowest with the true PE plus spring energy.
	# !
	# !
	# 
		$self->shiftvars(qw( BHDISTTHRESH BHMAXENERGY BHSTEPS BHCONV BHTEMP BHSTEPSIZE BHACCREJ BHK BHSFRAC ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BHINTERP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BHINTERPUSELOWEST" ){
		$self->vars("BHINTERPUSELOWEST" => 1);
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'CHECKENER') BHCHECKENERGYT=.TRUE.
	# !
	# !  Binary LJ parameters for use with the LP or LS atom types.
	# !
	# 
		$self->shiftvars(qw( UNSTRING BHSTEPSMIN ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BHINTERPUSELOWEST => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BINARY" ){
		$self->vars("BINARY" => 1);
	# !
	# !  Parameters for bisection runs
	# !
	# 
		$self->shiftvars(qw( NTYPEA EPSAB EPSBB SIGAB SIGBB ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BINARY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BISECT" ){
		$self->vars("BISECTT" => 1);
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'ICINTERP') ICINTERPT=.TRUE.
	# !
	# !  Debug printing for BISECT runs.
	# !
	# 
		$self->shiftvars(qw( BISECTMINDIST BISECTMAXENERGY BISECTSTEPS BISECTMAXATTEMPTS UNSTRING ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BISECT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BISECTDEBUG" ){
		$self->vars("BISECTDEBUG" => 1);
	}
	elsif($kw eq "BOND" ){
		$self->vars( NUBONDS => $self->vars(NUBONDS) + 1);
	
	#          NUBONDS = NUBONDS + 1
	}
	elsif($kw eq "BLN" ){
		#  General BLN model.
		$self->vars("BLNT" => 1);
		$self->shiftvars(qw( RK_R RK_THETA ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BLN => { $_ => $self->vars("$_") });
			}
		}
		open(BLNS,"<BLNsequence") || die $!;
		my @F;
		
		&skip_lines(\*BLNS,1);
		&read_line_vars(\*BLNS,[qw(LJREPBB LJATTBB)]);
		&read_line_vars(\*BLNS,[qw(LJREPLL LJATTLL)]);
		&read_line_vars(\*BLNS,[qw(LJREPNN LJATTNN)]);
		&skip_lines(\*BLNS,2);
		&read_line_vars(\*BLNS,[ qw( HABLN HBBLN HCBLN HDBLN )]);
		&read_line_vars(\*BLNS,[ qw( EABLN EBBLN ECBLN EDBLN )]);
		&read_line_vars(\*BLNS,[ qw( TABLN TBBLN TCBLN TDBLN )]);
		&read_line_char_array(\*BLNS,'BEADLETTER');
		&read_line_char_array(\*BLNS,'BLNSSTRUCT');
	
		close(BLNS);
		&eoo_arr("  BLN sequence of $vars{NATOMS} beads read: ",$arrays{BEADLETTER});
		&eoo_arr("	BLN dihedral types: ",$arrays{BLNSSTRUCT});
		&eoo_arr("	B-B LJ coefficients: ",[qw(LJREPBB LJATTBB)]);
		&eoo_arr("	L-L LJ coefficients: ",[qw(LJREPLL LJATTLL)]);
		&eoo_arr("	N-N LJ coefficients: ",[qw(LJREPNN LJATTNN)]);
		&eoo_arr("	Extended dihedral coefficients: ",[ qw( EABLN EBBLN ECBLN EDBLN ) ]);
		&eoo_arr("	Helix dihedral coefficients: ",[ qw( HABLN HBBLN HCBLN HDBLN ) ]);
		&eoo_arr("	Turn dihedral coefficients: ",[ qw( TABLN TBBLN TCBLN TDBLN ) ]);

	#          call param_arrayBLN(LJREP_BLN,LJATT_BLN,A_BLN,B_BLN,C_BLN,D_BLN,BEADLETTER,BLNSSTRUCT, &
	#      &                       LJREPBB, LJATTBB, LJREPLL, LJATTLL, LJREPNN, LJATTNN, &
	#      &                       HABLN, HBBLN, HCBLN, HDBLN, EABLN, EBBLN, ECBLN, EDBLN, TABLN, TBBLN, TCBLN, TDBLN, NATOMS)

	
	#          ALLOCATE(BEADLETTER(NATOMS),BLNSSTRUCT(NATOMS), &
	#      &            LJREP_BLN(NATOMS,NATOMS),LJATT_BLN(NATOMS,NATOMS),A_BLN(NATOMS),B_BLN(NATOMS),C_BLN(NATOMS),D_BLN(NATOMS))
	#          OPEN(UNIT=100,FILE='BLNsequence',STATUS='OLD')
	#          READ(100,*) DUMMYCH
	#          READ(100,*) LJREPBB, LJATTBB
	#          READ(100,*) LJREPLL, LJATTLL
	#          READ(100,*) LJREPNN, LJATTNN
	#          READ(100,*) DUMMYCH
	#          READ(100,*) DUMMYCH
	#          READ(100,*) HABLN, HBBLN, HCBLN, HDBLN
	#          READ(100,*) EABLN, EBBLN, ECBLN, EDBLN
	#          READ(100,*) TABLN, TBBLN, TCBLN, TDBLN
	#          DO J1=1,NATOMS-1
	#             READ(100,'(A1)',ADVANCE='NO') BEADLETTER(J1)
	#          ENDDO
	#          READ(100,'(A1)') BEADLETTER(NATOMS) ! this line is needed to advance the input line for the next read
	#          DO J1=1,NATOMS-3
	#             READ(100,'(A1)',ADVANCE='NO') BLNSSTRUCT(J1)
	#          ENDDO
	#          CLOSE(100)
	#          PRINT '(A,I8,A)','BLN sequence of ',NATOMS,' beads read:'
	#          WRITE(*,'(A1)',ADVANCE='NO') BEADLETTER(1:NATOMS)
	#          PRINT '(A)',' '
	#          PRINT '(A,I8,A)','BLN dihedral types:'
	#          WRITE(*,'(A1)',ADVANCE='NO') BLNSSTRUCT(1:NATOMS-3)
	#          PRINT '(A)',' '
	#          PRINT '(A,2F15.5)','B-B LJ coefficients: ',LJREPBB, LJATTBB
	#          PRINT '(A,2F15.5)','L-L LJ coefficients: ',LJREPLL, LJATTLL
	#          PRINT '(A,2F15.5)','N-N LJ coefficients: ',LJREPNN, LJATTNN
	#          PRINT '(A,4F15.5)','Helix    dihedral coefficients: ',HABLN,HBBLN,HCBLN,HDBLN
	#          PRINT '(A,4F15.5)','Extended dihedral coefficients: ',EABLN,EBBLN,ECBLN,EDBLN
	#          PRINT '(A,4F15.5)','Turn     dihedral coefficients: ',TABLN,TBBLN,TCBLN,TDBLN
	#          call param_arrayBLN(LJREP_BLN,LJATT_BLN,A_BLN,B_BLN,C_BLN,D_BLN,BEADLETTER,BLNSSTRUCT, &
	#      &                       LJREPBB, LJATTBB, LJREPLL, LJATTLL, LJREPNN, LJATTNN, &
	#      &                       HABLN, HBBLN, HCBLN, HDBLN, EABLN, EBBLN, ECBLN, EDBLN, TABLN, TBBLN, TCBLN, TDBLN, NATOMS)
	# !
	# !  Yimin Wang and Joel Bowman's water potential (2010)
	# !
	# 
	
	}
	elsif($kw eq "BOWMAN" ){
		$self->vars("BOWMANT" => 1);
	# !
	# !  BSMIN calculates a steepest-descent path using gradient only information
	# !  with convergence criterion GMAX for the RMS force and initial precision
	# !  EPS. The Bulirsch-Stoer algorithm is used.
	# !
	# 
		$self->shiftvars(qw( BOWMANPES BOWMANDIR ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BOWMAN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BSMIN" ){
		$self->vars("BSMIN" => 1);
		$self->shiftvars(qw( GMAX EPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( BSMIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "BULK" ){
		$self->vars("BULKT" => 1);
	# !
	# !  CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
	# !  CADPAC tells the program to read derivative information in
	# !         CADPAC format.                                        - default FALSE
	# !
	# 
	}
	elsif($kw eq "CADPAC" ){
		$self->vars("CADPAC" => 1);
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 10
	#             ENDIF
	#          ENDDO
	# 10       IF (NARGS.GT.2) THEN
	#          ELSE
	#             EDITIT='editit.' // SYS(1:LSYS)
	#          ENDIF
		$self->shiftvars(qw( SYS EDITIT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CADPAC => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CALCDIHE" ){
		$self->vars("CALCDIHE" => 1);
	# !
	# !  If READPATH is specified with CALCRATES then the rates are calculated from the
	# !  information in an existing path.info file without any stationary point searches.
	# !  A CONNECT or PATH run must be performed first unless READPATH is specified.
	# !
	# 
	}
	elsif($kw eq "CALCRATES" ){
		$self->vars("CALCRATES" => 1);
	# !
	# !  Double-ended connection keyword for ts candidates.
	# !
	# 
		$self->shiftvars(qw( TEMPERATURE HRED ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CALCRATES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CANDIDATES" ){
	# !
	# !  Virus capsid specification.
	# !
	# 
		$self->shiftvars(qw( CANDIDATES ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CANDIDATES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CAPSID" ){
		$self->vars("RIGIDBODY" => 1);
		$self->vars("ANGLEAXIS" => 1);
	#          HEIGHT=0.5D0
		$self->shiftvars(qw( CAPSRHO CAPSEPS2 CAPSRAD HEIGHT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CAPSID => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CAPSID2" ){
	# !         RIGIDBODY=.TRUE.
	# 
		$self->vars("ANGLEAXIS2" => 1);
	#          HEIGHT=0.5D0
	# 
	# ! starting from a given residue, use cartesians for everything
	# 
		$self->shiftvars(qw( CAPSRHO CAPSEPS2 CAPSRAD HEIGHT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CAPSID2 => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CARTRESSTART" ){
	# !
	# !  CASTEP tells the program to read derivative information in
	# !         CASTEP format.                                        - default FALSE
	# !
	# 
	#       ELSE IF ((WORD.EQ.'CASTEP').OR.(WORD.EQ.'CASTEPC')) THEN
		$self->vars("CASTEP" => 1);
	#          IF (WORD.EQ.'CASTEP') DFTP=.TRUE.
	#          IF (NARGS.GT.2) THEN
	#             CASTEPJOB=TRIM(ADJUSTL(CASTEPJOB)) // ' ' // TRIM(ADJUSTL(SYS))
	#          ELSE
	#             WRITE(*,'(A)') 'keywords> ERROR - CASTEP job or system unspecified'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 22
	#             ENDIF
	#          ENDDO
	# 22       CONTINUE
	# !
	# ! charmm stuff (DAE)
	# !
	# 
		$self->shiftvars(qw( CARTRESSTART CASTEPJOB SYS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CARTRESSTART => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CHARMM" ){
		$self->vars("CHRMMT" => 1);
	#          IF (.NOT.CISTRANS) THEN
		$self->vars("NOCISTRANS" => 1);
		$self->vars("CHECKOMEGAT" => 1);
	#          ENDIF
		$self->vars("CHECKCHIRALT" => 1);
	#          IF ((PERMDIST.OR.LOCALPERMDIST).AND.(NPERMSIZE(1).EQ.NATOMS)) THEN
	#             PRINT '(A)','keyword> ERROR - PERMDIST or LOCALPERMDIST is specfied for CHARMM, but there is no perm.allow file present'
	#             STOP
	#          ENDIF
	#          CALL CHALLOCATE(NATOMS)
	#          ALLOCATE(ATMASS(NATOMS))
	#          IF (MACHINE) THEN
	#               ! SAT: we will read in the coords ourselves and pass them to CHARMM {{{
	#               ! --- start ---
	#               ! read in the coords
	#               INQUIRE(IOLENGTH=J1) (Q(J),J=1,3*NATOMS)
	#               IF (FILTH2==0) THEN
	#                    OTEMP='points1.inp'
	#               ELSE
	#                    WRITE(OTEMP,*) FILTH2
	#                    OTEMP='points1.inp.'//TRIM(ADJUSTL(OTEMP))
	#               ENDIF
	#               OPEN(113,FILE=OTEMP,ACCESS='DIRECT',FORM='UNFORMATTED',STATUS='OLD',RECL=J1)
	#               READ(113,REC=1) (Q(J),J=1,3*NATOMS)
	#               IF (MAXVAL(Q)==0.0D0) THEN
	#                   PRINT *, 'Zero coordinates - stop'
	#                   CALL FLUSH(6,ISTAT)
	#                   STOP
	#               ENDIF
	#               CLOSE(113)
	#               ! --- end ---
	#               ! SAT: line below was intended to replace the block of code above
	#               ! (marked); unfortunately, due to the miscompilation with pgi this
	#               ! does not work. The compiler does not really want to reuse the
	#               ! code. Sigh...
	#               ! call ReadInpFile(Q)
	#               ! save them into CH. arrays and pass to CHARMM
	#               DO J1=1,NATOMS
	#                  CHX(J1)=Q(3*(J1-1)+1)
	#                  CHY(J1)=Q(3*(J1-1)+2)
	#                  CHZ(J1)=Q(3*(J1-1)+3)
	#               ENDDO
	#               CALL CHSETUP(CHX,CHY,CHZ,CHMASS,NATOM,TOPFILE,PARFILE)
	# !              CALL FILLICT(CHX,CHY,CHZ,DUMMY1,.TRUE.)
	# 
	#               CALL FILLICTABLE(Q)
	#               ! }}}
	#          ELSE
	#               ! charmm will read the coords and will return them to OPTIM via CH. vecs {{{
	#               CHX(1)=13.13d13 ! this way we will tell CHARMM to save its coords into CH. arrays; otherwise it will
	#               CALL CHSETUP(CHX,CHY,CHZ,CHMASS,NATOM,TOPFILE,PARFILE)
	#               ! }}}
	#          ENDIF ! SAT
	#          CALL CHSETZSYMATMASS
	#          IF (FILTH.NE.0) THEN
	#             OPEN(UNIT=20,FILE='coords.read',STATUS='REPLACE')
	#             CLOSE(20)
	#          ENDIF
	# !        NATOMS=NATOM  ! should already know NATOMS from getparams
	# 
	#          IF (NATOM /= NATOMS) THEN
	#             WRITE(*,'(A)') 'No. of atoms in "input.crd" and file specified in CHARMM part of odata conflict'
	#             PRINT *, 'NATOM,NATOMS=',NATOM, NATOMS
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          CALL CHALLOCATE(NATOMS)
	#          CALL CHSETDIHE
	# !       csw34> If FREEZERES specified, call CHRESTOATOM to populate the
	# !       FROZEN array (from ocharmm.src)
	# 
	#          IF (FREEZERES) CALL CHRESTOATOM(FROZENRES,FROZEN)
	#          IF (CONNECTT) CALL SETSEED
	# !         IF (CALCDIHE) CALL READREF(NATOMS)
	# 
	#          DO J1=1,NATOMS
	#             Q(3*(J1-1)+1)=CHX(J1)
	#             Q(3*(J1-1)+2)=CHY(J1)
	#             Q(3*(J1-1)+3)=CHZ(J1)
	#             ATMASS(J1) = CHMASS(J1)
	# !           PRINT *,'ATMASS',ATMASS(J1)
	# 
	#          ENDDO
	#          IF (TWISTDIHET) THEN
	#             CALL TWISTDIHE(Q,DMODE,DPERT)
	#          ENDIF
	#          IF (PERTDIHET) THEN
	#             CALL PERTDIHE(Q,CHPMIN,CHPMAX,CHNMIN,CHNMAX,ISEED)
	#          ENDIF
	#          IF (INTMINT) CALL GETNINT(NINTS)  ! DJW - this is OK because CHARMM is the last keyword!
	# !
	# 
	}
	elsif($kw eq "CHARMMTYPE" ){
	#          IF (NARGS.GT.1) THEN
	#             TOPFILE=TRIM(ADJUSTL(TOPFILE))
	#          ENDIF
	#          IF (NARGS.GT.2) THEN
	#             PARFILE=TRIM(ADJUSTL(PARFILE))
	#          ELSE
	#             WRITE(*,*) 'keywords> TOPFILE and PARFILE have to be defined for CHARMMTYPE'
	#             STOP
	#          ENDIF
	#          IF (TOPFILE(1:6).EQ."toph19") THEN
	#             CHARMMTYPE=2
	#          ELSEIF (TOPFILE(1:9).EQ."top_all22") THEN
	#             CHARMMTYPE = 1
	#          ELSE
	#              WRITE(*,*) 'keywords> TOPFILE ', TRIM(ADJUSTL(TOPFILE)),' is not recognised by OPTIM'
	#              STOP
	#          ENDIF
	#          WRITE(*,'(A,I2)') 'CHARMMTYPE set to ',CHARMMTYPE
	# !
	# ! If CHDEBUG is on, CHARMM related debug messages are printed
	# !
	# 
		$self->shiftvars(qw( TOPFILE PARFILE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CHARMMTYPE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CHDEBUG" ){
		$self->vars("CHDEBUG" => 1);
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'EDEBUG') EDEBUG=.TRUE.
	# 
	# !
	# ! CHARMM related keyword, avoids inversion around C_alpha
	# ! -- also implemented to AMBER (sf344)
	# 
		$self->shiftvars(qw( UNSTRING ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CHDEBUG => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CHECKCHIRALITY" ){
		$self->vars("CHECKCHIRALT" => 1);
	# !
	# !  If CHECKINDEX is .TRUE. and the BFGSTS routine converges an attempt is
	# !  made to count the number of negative Hessian eigenvalues using projection,
	# !  orthogonalization and iteration. We also need the opportunity to change the
	# !  parameters NEVL and NEVS within BFGSTS if BFGSTS isn t true.
	# !  CHECKINDEX can also be used with BFGSMIN and should understand NOHESS too.
	# !
	# 
	}
	elsif($kw eq "CHECKINDEX" ){
		$self->vars("CHECKINDEX" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
	# !
	# !  If the index found by checkindex does not correspond to BFGSMIN or BFGSTS then
	# !  CHECKCONT causes a pushoff along the eigenvector correpsonding to the softest
	# !  undesired negative eigenvalue.
	# !
	# 
		$self->shiftvars(qw( NEVS CEIG NEVL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CHECKINDEX => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CHECKCONT" ){
		$self->vars("CHECKCONT" => 1);
	# !
	# !  Check for internal minimum in constraint terms for INTBCONSTRAINT
	# !
	# 
	}
	elsif($kw eq "CONINT" ){
		$self->vars("CHECKCONINT" => 1);
	# !
	# !  CHINTERPOLATE controls the interpolation for BHINTERP using CHARMM's primitive
	# !  internal coordinates. The 1st argument has to be either BC or BI for the backbone
	# !  interpolation with Cartesians and Internals, respectively. The 2nd argument
	# !  has to be either SC or SI for the sidechain interpolation with Cartesians and
	# !  Internals, respectively. If DNEB is given as 3rd argument, this interpolation scheme
	# !  will be used for DNEB. If CHINTERPOLATE is not defined in the odata file the default is
	# !  that DNEB and BHINTERP are done in Cartesians
	# !
	# 
	}
	elsif($kw eq "CHINTERPOLATE" ){
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'BI') CHBIT=.TRUE.
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'SI') ICINTERPT=.TRUE.
	#          IF (NARGS.GT.3) THEN
	#             IF (TRIM(ADJUSTL(UNSTRING)).EQ.'DNEB') CHICDNEB=.TRUE.
	#          ENDIF
	# !
	# !  If BHINTERPolation, and CHRIGID is set for the CHARMM potential, rigid body
	# !  translation and rotation is applied to the peptides/proteins if more
	# !  than one peptide/protein is prsent.
	# !
	# 
		$self->shiftvars(qw( UNSTRING UNSTRING UNSTRING ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CHINTERPOLATE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CHRIGID" ){
		$self->vars("CHRIGIDT" => 1);
	# !
	# ! CISTRANS is a CHARMM related keyword, which allows cis-trans isomerisation of the peptide bond .
	# !
	# 
		$self->shiftvars(qw( PTRANS TRANSMAX PROT ROTMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CHRIGID => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CISTRANS" ){
	#          CISTRANS=.TRUE.
	# !
	# !  Sometimes have to modify the cold fusion limit when using high electric fields
	# !
	# 
	}
	elsif($kw eq "COLDFUSION" ){
	# !
	# !  Connect initial minimum in odata to final minimum in file finish - maximum
	# !  number of transiiton states=NCONNECT. Obsolete - use NEWCONNECT instead.
	# !
	# 
		$self->shiftvars(qw( COLDFUSIONLIMIT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( COLDFUSION => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CONNECT" ){
		$self->vars("CONNECTT" => 1);
	# !
	# !  Constraint potential for interpolation between minima.
	# !
	# 
		$self->shiftvars(qw( NCONNECT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CONNECT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CONPOT" ){
		$self->vars("CONPOTT" => 1);
	# !
	# ! jmc unres
	# ! Note also use some of the non-specific charmm keywords like INTMIN, NGUESS, TWISTTYPE etc...
	# !
	# 
		$self->shiftvars(qw( CPCONSTRAINTTOL CPCONSTRAINTDEL CPCONSTRAINTREP CPCONSTRAINREPCUT CPCONFRAC CPCONSEP CPREPSEP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CONPOT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CONSEC" ){
		$self->vars("CONSECT" => 1);
	#          DO J1=1,(NARGS-1)/2
	#          END DO
	#          IF (NARGS.GT.21) WRITE(*,'(A)') 'Too many sections requested - please adapt code!'
	#          NUMSEC=(NARGS-1)/2
	#          PRINT *,'CONSEC ',(STARTRES(J1),J1=1,10),(ENDRES(J1),J1=1,10), NUMSEC
	# !
	# !  CONVERGE n m INDEX/NOINDEX sets the convergence criteria for the maximum
	# !               unscaled step and RMS force                     - default n=0.0001, m=0.000001
	# !                                                           or m < 0.00001 .AND. n < m*100000
	# !               If NOINDEX is set the Hessian index isn t checked - the default is
	# !               INDEX.
	# !
	# 
	}
	elsif($kw eq "CONVERGE" ){
	#         IF (NARGS.GT.2) THEN
	#         ENDIF
	#         IF (NARGS.GT.3) THEN
	#            IF (WORD.EQ.'NOINDEX') INDEXT=.FALSE.
	#         ENDIF
	# !
	# !  Probably prints the copyright info?
	# !
	# 
		$self->shiftvars(qw( CONVU CONVR WORD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CONVERGE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "COPYRIGHT" ){
	#           CALL COPYRIGHT
	# !     CP2K tells the program to read derivative information in
	# !         CP2K format.                                        - default FALSE
	# !
	# 
	#       ELSE IF ((WORD.EQ.'CP2K').OR.(WORD.EQ.'CP2KC')) THEN
		$self->vars("CP2K" => 1);
	#          IF (WORD.EQ.'CP2K') DFTP=.TRUE.
	#          IF (NARGS.GT.2) THEN
	#             CP2KJOB=TRIM(ADJUSTL(CP2KJOB)) // ' ' // TRIM(ADJUSTL(SYS))
	#          ELSE
	#             WRITE(*,'(A)') 'keywords> ERROR - no CP2K system specified'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 281
	#             ENDIF
	#          ENDDO
	# 281      CONTINUE
	# !
	# !  CPMD tells the program to read derivative information in
	# !         CPMD format.                                        - default FALSE
	# !
	# 
	#       ELSE IF ((WORD.EQ.'CPMD').OR.(WORD.EQ.'CPMDC')) THEN
		$self->vars("CPMD" => 1);
	#          IF (WORD.EQ.'CPMDC') CPMDC=.TRUE.
	#          IF (NARGS.GT.1) THEN
	#          ELSE
	#             WRITE(*,'(A)') ' ERROR - no CPMD system specified'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 12
	#             ENDIF
	#          ENDDO
	# 12       CONTINUE
	#          CALL SYSTEM(' grep -c DUMMY ' // SYS(1:LSYS) // ' > temp ')
	#          OPEN(UNIT=7,FILE='temp',STATUS='OLD')
	#          READ(7,*) J1
	#          IF (J1.NE.1) THEN
	#             WRITE(*,'(A)') 'ERROR, no dummy line in CPMD input file'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	# !
	# !   Option to specify a different CPMD executible
	# !
	# 
		$self->shiftvars(qw( CP2KJOB SYS SYS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( COPYRIGHT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CPMD_COMMAND" ){
	# !
	# !  CUBIC: maintains cubic supercell for PV calculations
	# !
	# 
		$self->shiftvars(qw( CPMD_COMMAND ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( CPMD_COMMAND => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CUBIC" ){
	#          CUBIC=.TRUE.
	# !
	# !  For the growing string or evolving string double-ended
	# !  transition state search methods, use a cubic spline interpolation between
	# !  the image points.
	# !
	# 
	}
	elsif($kw eq "CUBSPL" ){
	#          CUBSPLT = .TRUE.
	# !
	# !  DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
	# !
	# !
	# !  Add a decahedral field to the potential of magnitude FTD.
	# !
	# 
	}
	elsif($kw eq "D5H" ){
		$self->vars("FIELDT" => 1);
		$self->vars("D5HT" => 1);
		$self->shiftvars(qw( FD5H ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( D5H => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DB" ){
		$self->vars("DBPT" => 1);
		$self->vars("RBAAT" => 1);
	#          IF (NARGS > 6) THEN
		$self->vars("EFIELDT" => 1);
	#          ENDIF
	#          NRBSITES = 3
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          NTSITES = NATOMS*NRBSITES/2
		$self->shiftvars(qw( DBEPSBB DBEPSAB DBSIGBB DBSIGAB DBPMU EFIELD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DB => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DBTD" ){
		$self->vars("DBPTDT" => 1);
		$self->vars("RBAAT" => 1);
	#          IF (NARGS > 6) THEN
		$self->vars("EFIELDT" => 1);
	#          ENDIF
	#          NRBSITES = 3
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          NTSITES = (NATOMS/2-1)*NRBSITES + 4
	# 
	# !
	# !  DCHECK  turns ON/OFF warnings about short interatomic distances
	# !                                                     - default ON
	# !
	# 
		$self->shiftvars(qw( DBEPSBB DBEPSAB DBSIGBB DBSIGAB DBPMU EFIELD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DBTD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DCHECK" ){
	#          IF (WW .EQ. 'ON' .OR. WW .EQ. ' ') THEN
		$self->vars("DCHECK" => 1);
	#          ELSE IF (WW .EQ. 'OFF') THEN
		$self->vars("DCHECK" => 0);
	#          ENDIF
	# !
	# !  DEBUG ON/OFF sets n=1 for EFSTEPS, VALUES, SUMMARY above     - default OFF
	# !
	# 
		$self->shiftvars(qw( WW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DCHECK => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DEBUG" ){
		$self->vars("BHDEBUG" => 1);
	#         IF (WW .EQ. 'ON' .OR. WW .EQ. ' ') THEN
		$self->vars("EFSTEPST" => 1);
		$self->vars("PGRAD" => 1);
	#           NGRADIENTS=1
	#           EFSTEPS=1
	#           NSUMMARY=1
	#           NVALUES=1
		$self->vars("DEBUG" => 1);
	#           PRINTOPTIMIZETS=.TRUE.
	#           DUMPNEBXYZ=.TRUE.
		$self->vars("DUMPINTXYZ" => 1);
	#           DUMPNEBPTS=.TRUE.
	#           DUMPNEBEOS=.TRUE.
		$self->vars("DUMPINTEOS" => 1);
	#         ENDIF
		$self->shiftvars(qw( WW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DEBUG => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DESMAXAVGE" ){
	# ! maximum average energy before double ended search method can stop
	# 
	# 
	# 
	# !         ! maximum energy jump in one step
	# !         ! for an image in a double-ended search method
	# 
	# !
	# !  Produces extra printing for the double-ended
	# !  transition state search method runs (DNEB, GS or ES).
	# !
	# 
		$self->shiftvars(qw( DESMAXAVGE DESMAXEJUMP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DESMAXAVGE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DESMDEBUG" ){
		$self->vars("DESMDEBUG" => 1);
	}
	elsif($kw eq "DESMINT" ){
	#          DESMINT = .TRUE.
	#          INTINTERPT = .FALSE. ! desmint and intinterp are mutually exclusive
	#          NATINT = .TRUE. ! must use natural internals for double ended search
	# !
	# !  DFTBT tells the program to call dftb for Tiffany s tight-binding.
	# !                                                  - default FALSE
	# 
	}
	elsif($kw eq "DFTB" ){
		$self->vars("DFTBT" => 1);
	# !
	# !  Initial diagonal elements for LBFGS
	# !
	# 
	}
	elsif($kw eq "DGUESS" ){
	# !
	# !  If DIJKSTRA is true then decide in newconnect uses Dijkstra;s algorithm in
	# !  deciding which connections to try next.
	# !  First argument on DIJKSTRA line controls the cost function. SAT
	# !
	# 
		$self->shiftvars(qw( DGUESS XDGUESS NEBDGUESS INTDGUESS GSDGUESS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DGUESS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DIJKSTRA" ){
	#          IF (NARGS.GT.1) THEN
	#             IF (TRIM(ADJUSTL(WW))=='EXP') THEN
	#                  EXPCOSTFUNCTION = .TRUE.
	#             ELSEIF (TRIM(ADJUSTL(WW))=='INDEX') THEN
	#                  INDEXCOSTFUNCTION = .TRUE.
	#             ELSEIF (trim(adjustl(WW))=='INTERP') THEN
	#                  INTERPCOSTFUNCTION = .TRUE.
	#                  IF (TRIM(ADJUSTL(WW))=='EXP') THEN
	#                     EXPCOSTFUNCTION = .TRUE.
	#                  ELSE
	# !                   CALL READI(COSTFUNCTIONPOWER)
	# 
	#                     READ(WW,'(I20)') COSTFUNCTIONPOWER
	#                  ENDIF
	#             ELSE IF (WW(1:1) /= ' ') THEN
	#                  READ(WW,'(I20)') COSTFUNCTIONPOWER
	#             ENDIF
	#             IF (NARGS.GT.2) THEN
	#                IF (trim(adjustl(WW))=='INTDISTANCE') THEN
	#                   IF (.NOT.INTINTERPT) THEN
	#                      PRINT*, "INTDISTANCE doesn,t work without INTINTERP"
	#                      PRINT*, "specify the latter before DIJKSRA in odata"
	#                   ELSE
	#                      INTDISTANCET = .TRUE.
	#                   ENDIF
	#                ELSE
	#                   READ(WW,*) DIJKSTRADMAX
	#                ENDIF
	#             ENDIF
	#          ENDIF
	# !
	# !  DIJKSTRALOCAL specifies an adjustable factor used to multiply the
	# !  distances between minima found within one DNEB cycle. Decreasing
	# !  this metric will encourage attempts to complete the connection, which
	# !  might otherwise never be tried if shorter distances exist. We are
	# !  trying to correct for the imperfect nature of the distance criterion
	# !  used for the DIJKSTRA metric in choosing new connection pairs.
	# !
	# 
		$self->shiftvars(qw( WW INTERPDIFF WW WW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DIJKSTRA => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DIJKSTRALOCAL" ){
	# !
	# !  Double well potential between first two atoms
	# !
	# 
		$self->shiftvars(qw( DIJKSTRALOCAL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DIJKSTRALOCAL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DOUBLE" ){
		$self->vars("DOUBLET" => 1);
	# !
	# !  DNEB RMS threshold for switching to NEB
	# !
	# 
	}
	elsif($kw eq "DNEBSWITCH" ){
	# !
	# !  Strings keyword.
	# !
	# 
		$self->shiftvars(qw( DNEBSWITCH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DNEBSWITCH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DQAGKEY" ){
	# !
	# !  Obsolete: create a trajectory between the endpoints by increasing
	# !  a spring constant. Sounds like MD steering, but it doesn`t actually
	# !  work very well!
	# !
	# 
		$self->shiftvars(qw( DQAGKEY ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DQAGKEY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DRAG" ){
		$self->vars("DRAGT" => 1);
	# !
	# !  DUMPALLPATHS prints a summary of all min-sad-min triples produced by NEWCONNECT to
	# !  file path.info. For each stationary point the energy, point group order and symbol,
	# !  Hessian eigenvalues and coordinates are given. Hessian eigenvalues are computed
	# !  if not yet calculated, otherwise they are saved during the CONNECT process.
	# !
	# 
	}
	elsif($kw eq "DUMPALLPATHS" ){
		$self->vars("DUMPALLPATHS" => 1);
	#          IF (FILTH.EQ.0) THEN
	#             WRITE(PINFOSTRING,'(A9)') 'path.info'
	#          ELSE
	#             WRITE(PINFOSTRING,'(A)') 'path.info.'//TRIM(ADJUSTL(FILTHSTR))
	#          ENDIF
	#          IF (MACHINE) THEN
	#               OPEN(UNIT=88,FILE=PINFOSTRING,STATUS='UNKNOWN',FORM='UNFORMATTED')
	#          ELSE
	#              OPEN(UNIT=88,FILE=PINFOSTRING,STATUS='UNKNOWN')
	#          ENDIF
	# !
	# !  Creates a file in pathsample min.data format for the minimum found
	# !  following a minimisation. Useful for a DPS initial path run in
	# !  creating entries for the two endpoints.
	# !  Can also be used with BHINTERP alone to generate a list of entries
	# !  for interpolated minima.
	# !
	# 
	}
	elsif($kw eq "DUMPDATA" ){
		$self->vars("DUMPDATAT" => 1);
	#          IF (FILTH.EQ.0) THEN
	#             WRITE(PINFOSTRING,'(A13)') 'min.data.info'
	#          ELSE
	#             WRITE(PINFOSTRING,'(A)') 'min.data.info.'//TRIM(ADJUSTL(FILTHSTR))
	#          ENDIF
	#          IF (MACHINE) THEN
	#               OPEN(UNIT=881,FILE=PINFOSTRING,STATUS='UNKNOWN',FORM='UNFORMATTED')
	#          ELSE
	#               OPEN(UNIT=881,FILE=PINFOSTRING,STATUS='UNKNOWN')
	#          ENDIF
	# !
	# !  Explicit dump of interpolation EofS for intlbfgs. Should be set .TRUE. if DEBUG is set.
	# !
	# 
	}
	elsif($kw eq "DUMPINTEOS" ){
		$self->vars("DUMPINTEOS" => 1);
	# !
	# !  Explicit dump of EofS.neb for DNEB. Should be set .TRUE. if DEBUG is set.
	# !
	# 
		$self->shiftvars(qw( DUMPINTEOSFREQ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPINTEOS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPNEBEOS" ){
	#           DUMPNEBEOS=.TRUE.
	# !
	# !  Explicit dump of something for DNEB. Should be set .TRUE. if DEBUG is set.
	# !
	# 
		$self->shiftvars(qw( DUMPNEBEOSFREQ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPNEBEOS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPNEBPTS" ){
	#           DUMPNEBPTS=.TRUE.
	# !
	# !  Explicit dump of image coordinates in xyz format for intlbfgs. Should
	# !  be set .TRUE. if DEBUG is set.
	# !
	# 
		$self->shiftvars(qw( DUMPNEBPTSFREQ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPNEBPTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPINTXYZ" ){
		$self->vars("DUMPINTXYZ" => 1);
	# !
	# !  Explicit dump of image coordinates in xyz format for DNEB. Should
	# !  be set .TRUE. if DEBUG is set.
	# !
	# 
		$self->shiftvars(qw( DUMPINTXYZFREQ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPINTXYZ => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPNEBXYZ" ){
	#           DUMPNEBXYZ=.TRUE.
	# !
	# !  DUMPPATH prints a summary of a min-sad-min-...-min path produced by CONNECT to
	# !  file path.info. For each stationary point the energy, point group order and symbol,
	# !  Hessian eigenvalues and coordinates are given. Hessian eigenvalues are computed
	# !  if not yet calculated, otherwise they are saved during the CONNECT process.
	# !
	# 
		$self->shiftvars(qw( DUMPNEBXYZFREQ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPNEBXYZ => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPPATH" ){
		$self->vars("DUMPPATH" => 1);
	#          IF (FILTH.EQ.0) THEN
	#             WRITE(PINFOSTRING,'(A9)') 'path.info'
	#          ELSE
	#             WRITE(PINFOSTRING,'(A)') 'path.info.'//TRIM(ADJUSTL(FILTHSTR))
	#          ENDIF
	#          IF (MACHINE) THEN
	#               OPEN(UNIT=88,FILE=PINFOSTRING,STATUS='UNKNOWN',FORM='UNFORMATTED')
	#          ELSE
	#               OPEN(UNIT=88,FILE=PINFOSTRING,STATUS='UNKNOWN')
	#          ENDIF
	# !
	# !  If DUMPSP is true then OPTIM will dump minima and ts data in the pathsample format
	# !
	# 
	}
	elsif($kw eq "DUMPSP" ){
		$self->vars("DUMPSP" => 1);
	# !
	# !  DUMPVECTOR switches on dumping of eigenvectors to file
	# !              vectors.dump                                     - default OFF
	# !  ALLSTEPS dumps the vector(s) at each step. ALLVECTORS dumps all the vectors.
	# !  The defaults are for only the vector corresponding to the softest non-zero
	# !  eigenvalue to be dumped for the last step.
	# !
	# 
	}
	elsif($kw eq "DUMPVECTOR" ){
		$self->vars("DUMPV" => 1);
	#         IF (NARGS.GT.1) THEN
	#            IF (WORD.EQ.'ALLSTEPS') ALLSTEPS=.TRUE.
	#            IF (WORD.EQ.'ALLVECTORS') ALLVECTORS=.TRUE.
	#            IF (WORD.EQ.'MWVECTORS') MWVECTORS=.TRUE.
	#         ENDIF
	#         IF (NARGS.GT.2) THEN
	#            IF (WORD.EQ.'ALLSTEPS') ALLSTEPS=.TRUE.
	#            IF (WORD.EQ.'ALLVECTORS') ALLVECTORS=.TRUE.
	#            IF (WORD.EQ.'MWVECTORS') MWVECTORS=.TRUE.
	#         ENDIF
	#         IF (NARGS.GT.3) THEN
	#            IF (WORD.EQ.'ALLSTEPS') ALLSTEPS=.TRUE.
	#            IF (WORD.EQ.'ALLVECTORS') ALLVECTORS=.TRUE.
	#            IF (WORD.EQ.'MWVECTORS') MWVECTORS=.TRUE.
	#         ENDIF
	# !
	# !  EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	# !
	# !
	# !  EDIFFTOL specifies the maximum energy difference between permutational isomers in connect.
	# !
	# 
		$self->shiftvars(qw( WORD WORD WORD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPVECTOR => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "EDIFFTOL" ){
	# !
	# !  Specify an electric field in the z-direction, units are V/A
	# !  So far only implemented for use with TIPnP potentials
	# !
	# 
		$self->shiftvars(qw( EDIFFTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( EDIFFTOL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "EFIELD" ){
	# !
	# !  EFSTEPS n print the unscaled steps calculated for each mode
	# !          every n cycles                                       - default OFF
	# !
	# 
		$self->shiftvars(qw( EFIELD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( EFIELD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "EFSTEPS" ){
		$self->vars("EFSTEPST" => 1);
	# !
	# !  Calculate analytical Hessian and normal mode frequencies at end of run.
	# !  ENDHESS is only intended for use in single geometry optimisations, and
	# !  should not be needed for CONNECT or PATH runs if DUMPPATH is specified.
	# !  If the argument NENDHESS is omitted then all the eigenvalues are
	# !  calculated - otherwise just the lowest NENDHESS.
	# !
	# 
		$self->shiftvars(qw( EFSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( EFSTEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ENDHESS" ){
		$self->vars("ENDHESS" => 1);
	# !
	# !  Calculate numerical Hessian and normal mode frequencies at end of run.
	# !  Required if DUMPPATH or ENDHESS is specified for an UNRES run,
	# !  in which case it`s an internal coordinate Hessian, or for other potentials
	# !  that lack analytic second derivatives.
	# !
	# 
		$self->shiftvars(qw( NENDHESS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ENDHESS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ENDNUMHESS" ){
		$self->vars("ENDNUMHESS" => 1);
	# !
	# !
	# !
	# 
	}
	elsif($kw eq "ERROREXIT" ){
	#          PRINT *, 'ERROR EXIT'
	#          CALL FLUSH(6,ISTAT)
	#          STOP
	# !
	# !  Cutoff below which Hessian eigenvalues are considered to be zero.
	# !
	# 
	}
	elsif($kw eq "EVCUT" ){
	# !
	# !  Specify evolving strings.
	# !
	# 
		$self->shiftvars(qw( EVCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( EVCUT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "EVOLVESTRING" ){
	#          EVOLVESTRINGT = .TRUE.
	# !
	# !  sf344> extra repulsive LJ site for PY ellipsoids
	# !
	# 
	}
	elsif($kw eq "EXTRALJSITE" ){
		$self->vars("LJSITE" => 1);
	#           MAXINTERACTIONS=1
	#          IF(NARGS.GT.3) THEN
	#           WRITE(MYUNIT,'(A,3F8.3)') ' keyword> primary and secondary apex sites will be used, epsilon and heights: ', &
	#      &                              PEPSILON1(1), PSCALEFAC1(1), PSCALEFAC2(1)
	#           IF(.NOT.LJSITEATTR) THEN
	#                 MAXINTERACTIONS=3
	#           ELSE
	#                 MAXINTERACTIONS=4
	#           END IF
	#          ELSE
	#           WRITE(MYUNIT,'(A,2F8.3)') ' keyword> primary apex sites will be used, epsilon and height: ', PEPSILON1(1), PSCALEFAC1(1)
	#          END IF
	#          IF(NARGS.GT.4) THEN           ! binary ellipsoidal clusters will be set up only for two apex sites, not one
	# ! we also won't use the sigma parameter from now on, epsilon is enough for repulsive sites
		$self->vars("BLJSITE" => 1);
	#            CALL READF(PEPSILON1(3))     ! this is epsilon for the interaction between A and B type ellipsoids
	#            MAXINTERACTIONS=3 ! attractive secondary apex sites not incorporated for binary systems
	#            WRITE(MYUNIT,'(A,3F8.3)') ' keyword> binary system with primary and secondary apex sites, ' // &
	#      &  'epsilon and heights for 2nd type particle: ', PEPSILON1(2), PSCALEFAC1(2), PSCALEFAC2(2)
	#          END IF
	}
	elsif($kw eq "EXTRALJSITEATTR" ){
		$self->vars("LJSITE" => 1);
		$self->vars("LJSITEATTR" => 1);
	#          WRITE(MYUNIT,'(A,4F8.3)') 'keyword> primary and secondary apex sites '// &
	#      &                             'with normal LJ attraction, sigmas and epsilons: ', &
	#      &                             PSIGMAATTR(1), PEPSILONATTR(1), PSIGMAATTR(2), PEPSILONATTR(2)
	#          MAXINTERACTIONS=4
	}
	elsif($kw eq "LJSITECOORDS" ){
		$self->vars("LJSITECOORDST" => 1);
	}
	elsif($kw eq "PYBINARY" ){
		$self->vars("PYBINARYT" => 1);
		$self->vars("ANGLEAXIS2" => 1);
		$self->vars("RBAAT" => 1);
		$self->vars("ELLIPSOIDT" => 1);
		$self->vars("RADIFT" => 1);
	#          NRBSITES = 1
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          IF(NARGS.GT.16) THEN
		$self->vars("PARAMONOVCUTOFF" => 1);
	#             PCUTOFF=PCUTOFF*PYSIGNOT
	#             write (MYUNIT,*) "PY Potential. PCutoff ON:",PCUTOFF
	#          END IF
	#          IF(.NOT.ALLOCATED(PYA1bin)) ALLOCATE(PYA1bin(NATOMS/2,3))
	#          IF(.NOT.ALLOCATED(PYA2bin)) ALLOCATE(PYA2bin(NATOMS/2,3))
	#          DO J1=1,NATOMS/2
	#           IF(J1<=PYBINARYTYPE1) THEN
	#            PYA1bin(J1,:)=PYA11(:)
	#            PYA2bin(J1,:)=PYA21(:)
	#           ELSE
	#            PYA1bin(J1,:)=PYA12(:)
	#            PYA2bin(J1,:)=PYA22(:)
	#           END IF
	#          END DO
	# !
	# !  Obsolete. Allows for extra steps in LBFGS minimisations for CHARMM.
	# !
	# 
		$self->shiftvars(qw( PYBINARYTYPE1 PYSIGNOT PYEPSNOT PCUTOFF ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PYBINARY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "EXTRASTEPS" ){
	# !
	# !  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	# !
	# !
	# !  Distance dependent dielectric for Paul Mortenson`s amber
	# !
	# 
		$self->shiftvars(qw( EXTRASTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( EXTRASTEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FAKEWATER" ){
		$self->vars("FAKEWATER" => 1);
	#          WRITE (*,'(A)') ' SETTINGS Distance dependent dielectric will be used'
	# !
	# !  Integer variable to distinguish output files from parallel maiden jobs
	# !
	# 
	}
	elsif($kw eq "FILTH" ){
	#          IF (FILTH.EQ.0) THEN
	#          ELSE
	#             WRITE(*,'(A)') 'WARNING **** FILTH keyword in odata was overridden by command line argument'
	#          ENDIF
	# !
	# !  Specifies that FIXIMAGE should be set permanently after step
	# !  FIXAFTER. This effectively freezes the interacting images in different supercells
	# !  for calculations with periodic boundary conditions.
	# !
	# 
		$self->shiftvars(qw( FILTH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FILTH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FIXAFTER" ){
	# !
	# !  Strings keyword.
	# !
	# 
		$self->shiftvars(qw( FIXAFTER ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FIXAFTER => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FIXATMS" ){
	#          FIXATMS = .TRUE.
	# !
	# !  Fix uphill direction until force changes sign.
	# !  T12FAC is the fraction of the first collision time to be used in HSMOVE
	# !
	# 
	}
	elsif($kw eq "FIXD" ){
		$self->vars("FIXD" => 1);
	#          NMOVE=1
	# !
	# !  FRACTIONAL: constant pressure calculation using fractional coordinates
	# !
	# 
		$self->shiftvars(qw( T12FAC DTHRESH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FIXD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FRACTIONAL" ){
		$self->vars("FRACTIONAL" => 1);
	# !
	# !  Frozen atoms.
	# !
	# 
	}
	elsif($kw eq "FREEZE" ){
		$self->vars("FREEZE" => 1);
	#          DO J1=1,NARGS-1
	#             NFREEZE=NFREEZE+1
	#             FROZEN(NDUM)=.TRUE.
	#          ENDDO
	# 
	# ! csw34
	# ! Frozen residues (to be converted to frozen atoms)
	# !
	# 
		$self->shiftvars(qw( NDUM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FREEZE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FREEZERES" ){
		$self->vars("FREEZE" => 1);
		$self->vars("FREEZERES" => 1);
	# ! The FROZENRES array is then filled with the residue number from the
	# ! data file
	# 
	#          DO J1=1,NARGS-1
	#             FROZENRES(NDUM)=.TRUE.
	#          ENDDO
	# ! Finally, the frozen residue numbers are converted into frozen atom
	# ! numbers. This is also forcefield dependant and must be done when we
	# ! know which forcefield to use (i.e. in the CHARMM block above)
	# !
	# ! csw34> FREEZEGROUP centreatom radius
	# ! FREEZEs all atoms within radius angstroms of centreatom (labelled by index)
	# !
	# 
		$self->shiftvars(qw( NDUM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FREEZERES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FREEZEGROUP" ){
		$self->vars("FREEZE" => 1);
	#          FREEZEGROUPT=.TRUE.
		$self->shiftvars(qw( GROUPCENTRE GROUPRADIUS FREEZEGROUPTYPE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FREEZEGROUP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "DUMPMODE" ){
	#                 IF(DUMPV.AND.MWVECTORS) THEN
	#                         DO J1=1,NARGS-1
	#                                 DUMPMODEN(NDUM)=.TRUE.
	#                         ENDDO
	#                 ENDIF
	#          IF ((PERMDIST.OR.LOCALPERMDIST).OR.PERMDISTINIT) THEN
	#             NDUMMY=0
	#             DO J1=1,NPERMGROUP
	#                DO J2=1,NPERMSIZE(J1)
	#                   IF (FROZEN(PERMGROUP(NDUMMY+J2))) THEN
	#                      PRINT '(A,I8,A)',' keyword> ERROR atom ',PERMGROUP(NDUMMY+J2),' cannot be frozen and permuted'
	#                      STOP
	#                   ENDIF
	#                ENDDO
	#                NDUMMY=NDUMMY+NPERMSIZE(J1)
	#             ENDDO
	#          ENDIF
	# !
	# !  Strings keyword.
	# !
	# 
		$self->shiftvars(qw( NDUM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( DUMPMODE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "FREEZENODES" ){
		$self->vars("FREEZENODEST" => 1);
	# !
	# !  GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
	# !
	# !
	# !  GAMESS-UK tells the program to read derivative information in
	# !         GAMESS-UK format.                                        - default FALSE
	# 
		$self->shiftvars(qw( FREEZETOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( FREEZENODES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GAMESS-UK" ){
		$self->vars("GAMESSUK" => 1);
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 112
	#             ENDIF
	#          ENDDO
	# 112       IF (NARGS.GT.2) THEN
	#          ELSE
	#             EDITIT='editit.' // SYS(1:LSYS)
	#          ENDIF
	# !
	# !  GAMESS-US tells the program to read derivative information in
	# !         GAMESS-US format.                                        - default FALSE
	# 
		$self->shiftvars(qw( SYS EDITIT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$chvars{"GAMESS-UK"}{$_}=$self->vars("$_");
			}
		}
	}
	elsif($kw eq "GAMESS-US" ){
		$self->vars("GAMESSUS" => 1);
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 111
	#             ENDIF
	#          ENDDO
	# 111       IF (NARGS.GT.2) THEN
	#          ELSE
	#             EDITIT='editit.' // SYS(1:LSYS)
	#          ENDIF
	# !
	# !  GAUSSIAN tells the program to read derivative information in
	# !           Gaussian92 format.                                  - default FALSE
	# 
		$self->shiftvars(qw( SYS EDITIT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$chvars{"GAMESS-US"}{$_}=$self->vars("$_");
			}
		}
	}
	elsif($kw eq "GAUSSIAN" ){
		$self->vars("GAUSSIAN" => 1);
	# 
	# !     DC430 >
	# 
	# 
	}
	elsif($kw eq "GB" ){
		$self->vars("GBT" => 1);
		$self->vars("RBAAT" => 1);
	#          GBCHI    = (GBKAPPA ** 2 - 1.D0) / (GBKAPPA ** 2 + 1.D0)
	#          GBCHIPRM = (GBKAPPRM**(1.D0/GBMU)-1.D0) / (GBKAPPRM**(1.D0/GBMU)+1.D0)
		$self->shiftvars(qw( GBKAPPA GBKAPPRM GBMU GBNU GBSIGNOT GBEPSNOT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GB => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GBD" ){
		$self->vars("GBDT" => 1);
		$self->vars("RBAAT" => 1);
	#          GBCHI    = (GBKAPPA ** 2 - 1.D0) / (GBKAPPA ** 2 + 1.D0)
	#          GBCHIPRM = (GBKAPPRM**(1.D0/GBMU)-1.D0) / (GBKAPPRM**(1.D0/GBMU)+1.D0)
	# 
	# !     -----------------------------
	# !  GDIIS x y z  x=cutoff on previous RMS force below which GDIIS
	# !               may be applied, y=NDIIA the dimension of the DIIS
	# !               problem to solve, z=NINTV the interval between
	# !               GDIIS steps                                     - default OFF
	# !
	# 
		$self->shiftvars(qw( GBKAPPA GBKAPPRM GBMU GBNU GBSIGNOT GBEPSNOT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GBD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GDIIS" ){
	#         PRINT '(A)','keyword> GDIIS keyword not available'
	#         STOP
	# !       IF (NARGS.LT.4) THEN
	# !          DTEST=.FALSE.
	# !          PRINT*,'Error in GDIIS input - insufficient items'
	# !       ELSE
	# !          DTEST=.TRUE.
	# !          CALL READF(PCUT)
	# !          CALL READI(NDIIA)
	# !          CALL READI(NINTV)
	# !       ENDIF
	# !       IF (NDIIA.GT.NDIIS) THEN
	# !          WRITE(*,'(A,I6)') ' NDIIA too large=',NDIIA
	# !          STOP
	# !       ENDIF
	# !
	# !  GEOMDIFFTOL specifies the maximum displacement between identical permutational isomers in connect.
	# !
	# 
	}
	elsif($kw eq "GEOMDIFFTOL" ){
	# !
	# !  Paul Whitford Go model
	# !
	# 
		$self->shiftvars(qw( GEOMDIFFTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GEOMDIFFTOL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GOT" ){
		$self->vars("GOT" => 1);
	# !
	# !  GRADIENT n prints the gradients along the Hessian eigendirections
	# !             every n cycles                                    - default OFF
	# !
	# 
	}
	elsif($kw eq "GRAD4" ){
		$self->vars("GRAD4T" => 1);
	#          print *, 'use 4-point gradient'
	}
	elsif($kw eq "GRADIENTS" ){
		$self->vars("PGRAD" => 1);
	# !
	# !  GRADSQ specifies optimisation of the modulus gradient. This is a really bad idea!
	# !
	# 
		$self->shiftvars(qw( NGRADIENTS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GRADIENTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GRADSQ" ){
		$self->vars("GRADSQ" => 1);
	# !
	# !  Approximation to use for the gradient in DNEB routine NEB/grad.f90 - default is "dneb"
	# !
	# 
		$self->shiftvars(qw( GSTHRESH NSPECIAL NALLOW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GRADSQ => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GRADTYPE" ){
	# !
	# !  Attempt to interpolate between endpoints using a great circle. Not a huge success.
	# !
	# 
		$self->shiftvars(qw( GRADTYPE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GRADTYPE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GREATCIRCLE" ){
		$self->vars("GREATCIRCLET" => 1);
	# !
	# ! EF: growing strings
	# ! number of images and iterations for first iteration;
	# ! reparametrization tolerance, growth tolerance, convergence tolerance
	# ! maximum LBFGS step; LBFGS memory
	# !
	# 
		$self->shiftvars(qw( GCMXSTP GCIMAGE GCSTEPS GCCONV ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GREATCIRCLE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GROWSTRING" ){
		$self->vars("GROWSTRINGT" => 1);
	#          FCD = .TRUE.
	# !
	# !  Set the maximum total iteration density for the
	# !  growing string method. This specifies the maximum evolution iterations allowed per
	# !  total image number, including the iterations while the string is still
	# !  growing. If {\it itd\/} is less than 0, then this parameter is turned off
	# !  and there is no limit on the total iterations (this is the default).
	# !
	# 
		$self->shiftvars(qw( nnNIMAGE GSITERDENSITY REPARAMTOL GSGROWTOL GSCONV GSMXSTP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GROWSTRING => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GSMAXTOTITD" ){
	# !
	# !  Try to guess an interpolated path for sequential coordinate changes.
	# !  GSTEPS is the number of step to be tried for each sequential coordinate.
	# !  MAXGCYCLES is the number of sweeps through pairwise exchanges
	# !  GTHRESHOLD is the coordinate change above which sequential changes are considered.
	# !  MAXINTE is the convergence criterion for the maximum allowed interpolated energy.
	# !
	# 
		$self->shiftvars(qw( GSMAXTOTITD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GSMAXTOTITD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GUESSPATH" ){
	#          GUESSPATHT=.TRUE.
	# !        CALL READF(MAXINTE)
	# !
	# !  Use dihedral twisting in place of DNEB for
	# !  transition state guesses with CONNECT for CHARMM and UNRES.
	# !
	# 
		$self->shiftvars(qw( GSTEPS MAXGCYCLES GTHRESHOLD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GUESSPATH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GUESSTS" ){
		$self->vars("GUESSTST" => 1);
		$self->shiftvars(qw( GUESSTHRESH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GUESSTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "GUPTA" ){
	# !
	# !  HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	# !
	# !  For the growing string or evolving string double-ended
	# !  transition state search method, use the method described in the appendix of
	# !  Peters et al\cite{PetersHBC04} to calculate the Newton-Raphston search
	# !  direction. Namely, the Hessian is approximated based on changes in the
	# !  gradient, and the tangential component of $-\mathbf{Hf^\perp}$ is projected
	# !  out. By default, the Hessian used is actually an approximation to the
	# !  derivative matrix of $f^\perp$ rather than the gradient.
	# !
	# 
		$self->shiftvars(qw( GUPTATYPE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( GUPTA => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "HESSGRAD" ){
	#          HESSGRAD = .TRUE.
	# !
	# !  HIGHESTIMAGE - only use the highest non-endpoint image in a double-ended
	# !  MECCANO-type run.
	# !
	# 
	}
	elsif($kw eq "HIGHESTIMAGE" ){
	#          HIGHESTIMAGE=.TRUE.
	# !
	# !  HUPDATE specifies that a Hessian updating procedure should be used.
	# !
	# 
	}
	elsif($kw eq "HUPDATE" ){
		$self->vars("HUPDATE" => 1);
	#         NHUP=0
	#         IF (NARGS.GT.1) THEN
	#         ENDIF
	#         IF (NARGS.GT.2) THEN
	#         ENDIF
	#         IF (NARGS.GT.3) THEN
	#         ENDIF
	# !
	# !  Hybrid BFGS/eigenvector-following minimisation.
	# !
	# 
		$self->shiftvars(qw( NSTHUP INTHUP PHIG ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( HUPDATE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "HYBRIDMIN" ){
		$self->vars("HYBRIDMINT" => 1);
	#          CALL READI(HMNEVS)      ! maximum steps to converge smallest eigenvalue in Rayleigh-Ritz
	#          CALL READI(HMNBFGSMAX1) ! maximum tangent space LBFGS steps if eigenvalue unconverged
	#          CALL READI(HMNBFGSMAX2) ! maximum tangent space LBFGS steps if eigenvalue converged
	#          CALL READF(HMCEIG)      ! convegence criterion for eigenvalue
	#          CALL READF(HMMXSTP)     ! maximum step size for EF steps
	#          CALL READI(HMNSTEPS)    ! maximum number of hybrid minimisation steps
	#          CALL READF(HMEVMAX)     ! If the lowest eigenvalue goes above HMEVMAX then exit
	#          CALL READA(HMMETHOD)    ! Choose between EF and Page-McIver steepest-descent steps
	#          IF (NARGS.GT.9) THEN
	#             CALL READI(HMNEVL)   ! maximum steps for iterative calculation of largest eigenvalue if applicable
	#          ENDIF
	# !
	# !  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
	# !
	# !
	# !  Add an icosahedral field to the potential of magnitude FIH.
	# !
	# 
	}
	elsif($kw eq "IH" ){
		$self->vars("FIELDT" => 1);
		$self->vars("IHT" => 1);
	# !
	# !
	# !
	# 
		$self->shiftvars(qw( FIH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( IH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "IMSEP" ){
	# !
	# !  Search for a saddle of index INDEX if
	# !  SEARCH 2 is specified. See also KEEPINDEX. Also works with BFGSTS
	# !  up to a maximum of index 50, but NOIT must be set and a Hessian is needed.
	# !
	# 
		$self->shiftvars(qw( IMSEPMIN IMSEPMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( IMSEP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INDEX" ){
	# !
	# !  Use constraint potential for initial interpolation in each cycle.
	# !
	# 
		$self->shiftvars(qw( HINDEX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INDEX => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTCONSTRAINT" ){
		$self->vars("INTCONSTRAINTT" => 1);
	# !
	# ! Use the quasi-continuous metric for connection attempts, instead of distance.
	# !
	# 
	#          INTERPCOSTFUNCTION=.TRUE.
	# !
	# !  Use interpolation potential for LJ.
	# !
	# 
		$self->shiftvars(qw( INTCONSTRAINTTOL INTCONSTRAINTDEL INTCONSTRAINTREP INTCONSTRAINREPCUT INTCONFRAC INTCONSEP INTREPSEP INTSTEPS1 INTCONSTEPS INTRELSTEPS MAXCONE INTRMSTOL INTIMAGE MAXINTIMAGE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTCONSTRAINT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTLJ" ){
		$self->vars("INTLJT" => 1);
	# !
	# ! Use the quasi-continuous metric for connection attempts, instead of distance.
	# !
	# 
	#          INTERPCOSTFUNCTION=.TRUE.
	# !
	# !  Epsilon value in internal coordinate optimisation.
	# !
	# 
		$self->shiftvars(qw( INTLJSTEPS INTLJDEL INTLJTOL INTIMAGE INTLJEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTLJ => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTEPSILON" ){
	# 
	# !     back transformation cutoff for interpolation in internals
	# 
		$self->shiftvars(qw( INTEPSILON ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTEPSILON => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTERPBACKTCUT" ){
	# 
	# ! must set INTINTERP as well to use INTERPCHOICE
	# ! use internals or cartesian interpolation depending on which gives
	# ! the lower max energy
	# 
		$self->shiftvars(qw( INTERPBACKTCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTERPBACKTCUT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTERPCHOICE" ){
	#          INTERPCHOICE = .TRUE.
	}
	elsif($kw eq "INTINTERP" ){
	#          INTINTERPT = .TRUE. ! interpolate with internals
	#          NATINT = .TRUE. ! if interpolating, assume natural internal coords
	#          DESMINT = .FALSE. ! intinterp and desmint are mutually exclusive
	# 
	# ! when interpolating with internals, keep actual interpolation points.
	# ! don't distribute images between them to make them equidistant in cartesians
	# 
		$self->shiftvars(qw( NINTIM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTINTERP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTERPSIMPLE" ){
	#          INTERPSIMPLE = .TRUE.
	# !
	# !  Internal coordinate minimisation - do not use.
	# !   IMINCUT is the RMSG below which we take steps in internal coordinates
	# !
	# !
	# 
	}
	elsif($kw eq "INTMIN" ){
		$self->vars("INTMINT" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
	# 
	# ! align permutations of starting structures to match up internals
	# 
		$self->shiftvars(qw( IMINCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTMIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTMINPERM" ){
	#          INTMINPERMT = .TRUE.
	#          IF (NARGS.GT.1) THEN
	#             IF (WORD2.EQ."GLYCART") THEN
	#                GLYCART = .TRUE.
	#             ELSE
	#                PRINT*, "keyword error intminperm"
	#             ENDIF
	#          ENDIF
		$self->shiftvars(qw( WORD2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( INTMINPERM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "INTPARFILE" ){
	#          USEPARFILE = .TRUE.
	#          CALL READA(INTPARFILE) ! file with internals parameters
	# !
	# !  JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
	# !
	# !
	# !  KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
	# !
	# !
	# !  KEEPINDEX: specifies that INDEX is set with
	# !  the number of negative Hessian eigenvalues at the initial point.
	# !
	# 
	}
	elsif($kw eq "KEEPINDEX" ){
		$self->vars("KEEPINDEX" => 1);
	# 
	# !       csw34> Specify kT in wavenumbers, below which a normal mode is
	# !              determined to be thermally accessible. KTWN defaults to
	# !              room temperature (207.11cm-1). This is used by the
	# !              CHARMMDUMPMODES subroutine
	# 
	}
	elsif($kw eq "KTWN" ){
		$self->vars("KTWNT" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
	# 
	# !
	# !  LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	# !
	# !  Use Lanczos to diagonalize the Hamiltonian. Defaults for the three
	# !  associated parameters are ACCLAN=1.0D-8 SHIFTLAN=1.0D-2 CUTLAN=-1.0D0.
	# !
	# 
		$self->shiftvars(qw( KTWN ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( KTWN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "LANCZOS" ){
		$self->vars("LANCZOST" => 1);
	#          IF (NARGS.GT.1) THEN
	#          ENDIF
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
		$self->shiftvars(qw( ACCLAN SHIFTLAN CUTLAN ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( LANCZOS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "LWOTP" ){
		$self->vars("LWOTPT" => 1);
		$self->vars("RBAAT" => 1);
	#          NRBSITES = 3
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          NTSITES = NATOMS*NRBSITES/2
	}
	elsif($kw eq "LOWESTFRQ" ){
		$self->vars("LOWESTFRQT" => 1);
	# !
	# !  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
	# !
	# 
	}
	elsif($kw eq "MACHINE" ){
		$self->vars("MACHINE" => 1);
	# !
	# !  MASS ON/OFF takes steps with a fictitious "kinetic" metric   - default OFF
	# !
	# 
	}
	elsif($kw eq "MASS" ){
	#         IF (WW .EQ. 'ON' .OR. WW .EQ. ' ') THEN
		$self->vars("MASST" => 1);
	#         ELSE IF (WW .EQ. 'OFF') THEN
		$self->vars("MASST" => 0);
	#         ENDIF
	# !
	# !  Maximum value for the smaller barrier height that is allowed to constitute a connection during the
	# !  Dijkstra connection procedure.
	# !  MAXMAXBARRIER specifies a maximum for the maximum barrier.
	# !  MAXBARRIER requires both sides to be greater than MAXBARRIER to discard.
	# !
	# 
		$self->shiftvars(qw( WW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MASS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXBARRIER" ){
		$self->shiftvars(qw( MAXBARRIER ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXBARRIER => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXMAXBARRIER" ){
	# !
	# !  MAXBFGS x1 x2 x3 x4\/}: {\it x\/} specifies the maximum allowed step length in LBFGS
	# !  minimisations, {\it x1\/} for  normal minimisations, {\it x2\/} for Rayleigh-Ritz ratio
	# !  minimisation, {\it x3\/} for putting structures in closest coincidence with
	# !  {\bf mind} (NO LONGER USED!!), and {\it x4\/} for NEB minimisations. Default values all 0.2.
	# !
	# 
		$self->shiftvars(qw( MAXMAXBARRIER ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXMAXBARRIER => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXBFGS" ){
	# !
	# !  The maximum number of constraints to use in the constrained potential.
	# !  The deafult is 3.
	# !
	# 
		$self->shiftvars(qw( MAXBFGS MAXXBFGS MAXMBFGS MAXNEBBFGS MAXINTBFGS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXBFGS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXCON" ){
	# !
	# !  The maximum energy increase above which mylbfgs will reject a proposed step.
	# !
	# 
		$self->shiftvars(qw( MAXCONUSE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXCON => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXERISE" ){
	# !
	# !  Maximum number of failures allowed in a minimisation before giving up.
	# !
	# 
		$self->shiftvars(qw( MAXERISE XMAXERISE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXERISE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXFAIL" ){
	# !
	# !  For the growing string double-ended connection
	# !  method, specify a maximum number of steps allowed before another image is
	# !  added to the growing string. Default is 1000.
	# !
	# 
		$self->shiftvars(qw( NFAILMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXFAIL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXGROWSTEPS" ){
	# !
	# !  Will stop the entire job if the total string
	# !  length for the growing strings or evolving strings method goes above {\it x}
	# !  times the total number of images. This usually means that something is going
	# !  wrong with the string. Default is 1000.
	# !
	# 
		$self->shiftvars(qw( MAXGROWSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXGROWSTEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXLENPERIM" ){
	# !
	# !  Specifies the maximum value that the maximum step size
	# !  is allowed to rise to. The default value is $0.5$.
	# !
	# 
		$self->shiftvars(qw( MAXLENPERIM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXLENPERIM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXMAX" ){
	# !
	# !  MAXSTEP n specifies the maximum step size in real units      - default n=0.2
	# !  Applies to eigenvector-following and steepest-descent calculations.
	# !
	# 
		$self->shiftvars(qw( MAXMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXMAX => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXSTEP" ){
	# !
	# !  Maximum ts energy that is allowed to constitute a connection during the
	# !  Dijkstra connection procedure.
	# !
	# 
		$self->shiftvars(qw( MXSTP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXSTEP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MAXTSENERGY" ){
	# !
	# !  MECCANO - an interpolation via rigid rods of variable length
	# !
	# 
		$self->shiftvars(qw( MAXTSENERGY ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MAXTSENERGY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MECCANO" ){
	#          MECCANOT=.TRUE.
	#          CALL READF(MECIMDENS) ! now an image density
	#          CALL READI(MECMAXIMAGES)  ! maximum number of images
	#          CALL READF(MECITDENS) ! iteration density
	#          CALL READI(MECMAXIT)  ! maximum number of iterations
		$self->shiftvars(qw( MECLAMBDA MECDIST MECRMSTOL MECSTEP MECDGUESS MECUPDATE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MECCANO => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MINMAX" ){
	# !     ELSE IF (WORD.EQ.'MINBM') THEN
	# !        MINBMT = .TRUE.
	# !        CALL READI(MINBMNSAMP)
	# 
		$self->shiftvars(qw( MINMAX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MINMAX => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MINBACKTCUT" ){
	# !
	# !  MODE n  specifies the eigenvector to follow                  - default n=0
	# !
	# 
		$self->shiftvars(qw( MINBACKTCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MINBACKTCUT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MODE" ){
	#          IF (NARGS.GT.2) THEN
	#          ELSE
	# !           IVEC2=IVEC
	# 
	#          ENDIF
	# !
	# !  Attempt to morph between endpoints by taking steps towards or
	# !  away from the endpoint finish.
	# !
	# 
		$self->shiftvars(qw( IVEC IVEC2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MODE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MORPH" ){
		$self->vars("MORPHT" => 1);
	#          IF (MAXTSENERGY.EQ.1.0D100) MAXTSENERGY=MORPHEMAX
	# !
	# !  Movie dump for Paul Mortenson`s amber
	# !
	# 
		$self->shiftvars(qw( MORPHMXSTP MNBFGSMAX1 MNBFGSMAX2 MORPHEMAX MORPHERISE MSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MORPH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MOVIE" ){
		$self->vars("MOVIE" => 1);
	#          OPEN (UNIT=27, FILE='amber.movie', STATUS='UNKNOWN')
	# !
	# !  MSEVB parameters - probably shouldn`t be changed on a regular basis
	# !
	# 
	}
	elsif($kw eq "MSEVBPARAMS" ){
		$self->shiftvars(qw( shellsToCount maxHbondLength minHbondAngle OOclash_sq ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MSEVBPARAMS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "MSSTOCK" ){
		$self->vars("MSSTOCKT" => 1);
		$self->vars("RBAAT" => 1);
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          ALLOCATE(RBSTLA(NRBSITES,3))
	#          ALLOCATE(DPMU(NRBSITES))
	#          NTSITES = NATOMS*NRBSITES/2
	#          DO J1 = 1, NRBSITES
	#          ENDDO
	#          IF (NARGS > (NRBSITES+2)) THEN
		$self->vars("EFIELDT" => 1);
	#          ENDIF
	#          CALL DEFMULTSTOCK()
	#          IF (PERMDIST) THEN ! correct all permutations allowed if perm.allow is not given explicitly
	#             IF (NPERMSIZE(1).EQ.NATOMS) NPERMSIZE(1)=NATOMS/2
	#          ENDIF
	# 
	# !
	# !  NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
	# !
	# !  Specifies a tight-binding potential for sodium, silver and lithium
	# !
	# 
		$self->shiftvars(qw( NRBSITES EFIELD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( MSSTOCK => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NATB" ){
		$self->vars("NATBT" => 1);
	}
	elsif($kw eq "NATINT" ){
	#          NATINT = .TRUE.
	# !
	# 
	}
	elsif($kw eq "NCAP" ){
		$self->vars("NCAPT" => 1);
		$self->vars("RBAAT" => 1);
	#          HEIGHT   = 0.5D0
	#          NRBSITES = 6
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          NTSITES = NATOMS*NRBSITES/2
	# !
	# !  Nudged elastic band calculation using a maximum of NSTEPNEB steps with
	# !  NIMAGE images and RMS convergence criterion RMSNEB.
	# !
	# 
		$self->shiftvars(qw( CAPSRHO CAPSEPS2 CAPSRAD HEIGHT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NCAP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEB" ){
		$self->vars("NEBT" => 1);
		$self->shiftvars(qw( NSTEPNEB NIMAGE RMSNEB NEBMAG ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEB => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEBK" ){
	#          NEBKFINAL=NEBK
	#          NEBKINITIAL=NEBK
	#          NEBFACTOR=1.01D0
	# !
	# !  Read dneb guess images from file GUESSFILE, default name guess.xyz
	# !
	# 
		$self->shiftvars(qw( NEBK NEBKFINAL NEBFACTOR ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEBK => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEBREADGUESS" ){
	#          READGUESS=.TRUE.
	# !
	# !  Reseed DNEB images if they exceed a certain energy.
	# !
	# 
		$self->shiftvars(qw( GUESSFILE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEBREADGUESS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEBRESEED" ){
		$self->vars("NEBRESEEDT" => 1);
		$self->shiftvars(qw( NEBRESEEDINT NEBRESEEDEMAX NEBRESEEDBMAX NEBRESEEDDEL1 NEBRESEEDPOW1 NEBRESEEDDEL2 NEBRESEEDPOW2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEBRESEED => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEWCONNECT" ){
		$self->vars("NEWCONNECTT" => 1);
		$self->vars("CONNECTT" => 1);
	#          OPTIMIZETS = .TRUE.
	# !
	# !  If NEWCONNECT is specified the values read below are only used for the first cycle.
	# !  If NEWNEB is used with OLDCONNECT then the values read on the NEWNEB line are
	# !  used in every cycle. If NEWCONNECT is used then a NEWNEB line isn;t necessary.
	# !
	# 
		$self->shiftvars(qw( NCONMAX NTRIESMAX IMAGEDENSITY ITERDENSITY IMAGEMAX IMAGEINCR RMSTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEWCONNECT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NEWNEB" ){
		$self->vars("NEWNEBT" => 1);
	#          FCD=.TRUE.
	# !
	# !  NGUESS specifies the number of transition state guesses tried in GUESSTS for CHARMM
	# !  before switching back to NEB or NEWNEB.
	# !
	# 
		$self->shiftvars(qw( NNNIMAGE NITERMAX RMSTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NEWNEB => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NGUESS" ){
	# !
	# !  CHARMM related keyword to reject transition states
	# !  that connect two minima with different omega angles, i.e. to prevent cis-trans peptide
	# !  isomerisation.
	# !
	# 
		$self->shiftvars(qw( NGUESS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NGUESS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "UACHIRAL" ){
		$self->vars("UACHIRAL" => 1);
	}
	elsif($kw eq "NOCISTRANS" ){
	# ! is used in connect.f
		$self->vars("NOCISTRANS" => 1);
	# ! is used in NEWNEB
		$self->vars("CHECKOMEGAT" => 1);
	#          IF (NARGS.GT.2) THEN
	#             IF (TRIM(ADJUSTL(WW))=='RNA') THEN
		$self->vars("NOCISTRANSRNA" => 1);
	#                 write(*,*) ' keywords> NOCISTRANSRNA set to .TRUE.'
	#             ELSE IF (TRIM(ADJUSTL(WW))=='DNA') THEN
		$self->vars("NOCISTRANSDNA" => 1);
	#                 write(*,*) ' keywords> NOCISTRANSDNA set to .TRUE.'
	#             ELSE IF (TRIM(ADJUSTL(WW))=='ALWAYS') THEN
		$self->vars("CHECKCISTRANSALWAYS" => 1);
	#             ELSE IF (TRIM(ADJUSTL(WW))=='ALWAYSRNA') THEN
		$self->vars("CHECKCISTRANSALWAYSRNA" => 1);
	#             ELSE IF (TRIM(ADJUSTL(WW))=='ALWAYSDNA') THEN
		$self->vars("CHECKCISTRANSALWAYSDNA" => 1);
	#             ELSE
	#                 WRITE(*,*) ' keywords> ERROR - currently no other nocistrans options implemented than for RNA and DNA'
	#             ENDIF
	#          ENDIF
	# !
	# !  No frequencies should be evaluated or placed in the path.info file.
	# !
	# 
		$self->shiftvars(qw( MINOMEGA WW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NOCISTRANS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NOFRQS" ){
		$self->vars("NOFRQS" => 1);
	# !
	# !  No Hessian should be calculated during geometry optimisation.
	# !
	# 
	}
	elsif($kw eq "NOHESS" ){
		$self->vars("NOHESS" => 1);
	# !
	# !  If NOIT is true and we have a Hessian then use DSYEVR to calculate eigenvectors
	# !
	# 
	}
	elsif($kw eq "NOINTNEWT" ){
	#          ! dont use newtons method to converge internals back transform
	#          INTNEWT = .FALSE.
	}
	elsif($kw eq "NOIT" ){
		$self->vars("NOIT" => 1);
	# !
	# !  For the growing string or evolving string double-ended
	# !  transition state search methods, instead of using L-BFGS optimization to
	# !  evolve the strings, simply take steps in the direction of the perpendicular force.
	# !
	# 
	# 
	}
	elsif($kw eq "NOLBFGS" ){
	#          NOLBFGS = .TRUE.
	}
	elsif($kw eq "NONEBMIND" ){
	#           NEBMIND=.FALSE.
	#           PRINT *, 'keywords> Structures supplied to NEB will NOT be put in the closest coincidence'
	# !
	# !  NONLOCAL x y z factors for averaged Gaussian, Morse type 1 and Morse
	# !                 type 2 potentials to include                  - default 0 0 0
	# !
	# 
	}
	elsif($kw eq "NONLOCAL" ){
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
		$self->vars("FTEST" => 1);
	#          IF ((GFRACTION.EQ.0.0D0).AND.(MFRACTION1.EQ.0.0D0).AND. &
	#      &       (MFRACTION2.EQ.0.0D0)) FTEST=.FALSE.
		$self->shiftvars(qw( GFRACTION MFRACTION1 MFRACTION2 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NONLOCAL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NOPERMPROCHIRAL" ){
	#          NOPERMPROCHIRAL = .TRUE.
	# 
	# !
	# !  Reduce printing of coordinates.
	# !
	# 
	}
	elsif($kw eq "NOPOINTS" ){
		$self->vars("PRINTPTS" => 0);
	# !
	# !  Used in CHARMM transition state guessing procedure
	# !  together with TWISTTYPE. Setting randomcutoff very large prevents random
	# !  steps, and is recommended.
	# 
	# !
	# 
	}
	elsif($kw eq "NORANDOM" ){
		$self->vars("NORANDOM" => 1);
	# !
	# !  Whether to put periodic images back in the primary supercell.
	# !
	# 
		$self->shiftvars(qw( RANDOMCUTOFF ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NORANDOM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "NORESET" ){
		$self->vars("NORESET" => 1);
	}
	elsif($kw eq "NTIP" ){
	#          IF (TIPID /= 4) THEN
	#             PRINT *, 'NOT YET INCLUDED'
	#             STOP
	#          ENDIF
		$self->vars("NTIPT" => 1);
		$self->vars("RBAAT" => 1);
	#          NRBSITES = 4
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          ALLOCATE(STCHRG(NRBSITES))
	#          NTSITES = NATOMS*NRBSITES/2
	#          IF (PERMDIST) THEN ! correct all permutations allowed if perm.allow is not given explicitly
	#             IF (NPERMSIZE(1).EQ.NATOMS) NPERMSIZE(1)=NATOMS/2
	#          ENDIF
	# !
	# !  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
	# !
	# 
		$self->shiftvars(qw( TIPID ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( NTIP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ODIHE" ){
		$self->vars("ODIHET" => 1);
	#          WRITE(*,'(A)') 'ODIHE set: dihedral-angle order parameter will be calculated'
	#          WRITE(*,'(A)') 'using the reference structure supplied in ref.crd'
	# !
	# !  Add an octahedral field to the potential of magnitude FOH.
	# !
	# 
	}
	elsif($kw eq "OH" ){
		$self->vars("FIELDT" => 1);
		$self->vars("OHT" => 1);
		$self->shiftvars(qw( FOH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( OH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "OLDINTMINPERM" ){
	#          INTMINPERMT = .TRUE.
	#          OLDINTMINPERMT=.TRUE.
	# 
	# !
	# !  ONETEP tells the program to read derivative information in
	# !         ONETEP format.                                        - default FALSE
	# !
	# 
	#       ELSE IF ((WORD.EQ.'ONETEP').OR.(WORD.EQ.'ONETEPC')) THEN
		$self->vars("ONETEP" => 1);
	#          IF (WORD.EQ.'ONETEP') DFTP=.TRUE.
	#          IF (NARGS.GT.2) THEN
	#             ONETEPJOB=TRIM(ADJUSTL(ONETEPJOB)) // ' ' // TRIM(ADJUSTL(SYS)) // ' >& ' // TRIM(ADJUSTL(SYS)) // '.onetep'
	#          ELSE
	#             WRITE(*,'(A)') 'keywords> ERROR - ONETEP job or system unspecified'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          DO J1=1,80
	#             IF (SYS(J1:J1).EQ.' ') THEN
	#                LSYS=J1-1
	#                GOTO 24
	#             ENDIF
	#          ENDDO
	# 24       CONTINUE
	# !
	# !  Optimise TS with SQVV
	# !
	# 
		$self->shiftvars(qw( ONETEPJOB SYS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( OLDINTMINPERM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "OPTIMIZETS" ){
	#           OPTIMIZETS=.TRUE.
	# !
	# !  Calculates order parameters and theire derivatives wrt normal modes at the end of a geometry optimisation.
	# !  The 1st argument is the number of order parameters to be calculated. The next arguments then specify
	# !  the order parameters (defined by a 4 letters) and, if necessary, further information regarding this
	# !  order parameter can be given. If such details are not required, set them to -9999.
	# !  Following order parameters are currently supported: DIHEdral angles for CHARMM.
	# !
	# 
	}
	elsif($kw eq "ORDERPARAM" ){
		$self->vars("ORDERPARAMT" => 1);
	#           ALLOCATE(WHICHORDER(NORDER),ORDERNUM(NORDER))
	#           DO J1=1,NORDER
	#              ORDERNUM(J1)=-9999
	#           ENDDO
	# !
	# !  Remove overall trans/rot with SQVV
	# !
	# 
		$self->shiftvars(qw( NORDER ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ORDERPARAM => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ORT" ){
	#          ORT = .TRUE.
	}
	elsif($kw eq "OSASA" ){
		$self->vars("OSASAT" => 1);
	#          WRITE(*,'(A)') 'OSASA set: solvent accessible surface area order parameter will be calculated'
	#          WRITE(*,'(A,F3.1)') 'using probe radius ',RPRO
	# !
	# !  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
	# !
	# 
		$self->shiftvars(qw( RPRO ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( OSASA => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PAHA" ){
	#          IF (PAHID == 1) THEN
	#             NRBSITES = 12
	#          ELSEIF (PAHID == 2) THEN
	#             NRBSITES = 18
	#          ELSEIF (PAHID == 3) THEN
	#             NRBSITES = 24
	#          ELSEIF (PAHID == 4) THEN
	#             NRBSITES = 26
	#          ENDIF
		$self->vars("PAHAT" => 1);
		$self->vars("RBAAT" => 1);
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          ALLOCATE(RBSTLA(NRBSITES,3))
	#          ALLOCATE(STCHRG(NRBSITES))
	#          NTSITES = (NATOMS/2)*NRBSITES
	#          CALL DEFPAHA()
	#          IF (PAHID == 1) THEN
	#             NCARBON  = 6
	#             CALL DEFBENZENE()
	#          ELSEIF (PAHID == 2) THEN
	#             NCARBON  = 10
	#             CALL DEFNAPHTHALENE()
	#          ELSEIF (PAHID == 3) THEN
	#             NCARBON  = 14
	#             CALL DEFANTHRACENE()
	#          ELSEIF (PAHID == 4) THEN
	#             NCARBON  = 16
	#             CALL DEFPYRENE()
	#          ENDIF
		$self->shiftvars(qw( PAHID ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PAHA => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PARALLEL" ){
		$self->vars("PARALLEL" => 1);
	# !
	# !  PARAMS n1 n2 ... up to seven real input parameters used for the
	# !                   following atom types:
	# !  AX: Z*
	# !  M:  rho
	# !  MV: rho, delta
	# !  ME: N, M, BOXLENGTHS X, Y, Z AND CUTOFF (N, M ARE READ DOUBLE PRECISION)
	# !  JM: box lengths x, y, z and cutoff
	# !  SC: box lengths x, y, z and cutoff (epsilon, c, sigma are read from SCparams)
	# !  P6: box lengths x, y, z and cutoff
	# !  AU: epsilon, c, sigma
	# !  AG: epsilon, c, sigma
	# !  NI: epsilon, c, sigma
	# !
	# 
		$self->shiftvars(qw( NPROC ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PARALLEL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PARAMS" ){
	#          GALPHA=PARAM1
	#          MALPHA1=PARAM1
	#          MALPHA2=PARAM1
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
	#          IF (NARGS.GT.4) THEN
	#          ENDIF
	#          IF (NARGS.GT.5) THEN
	#          ENDIF
	#          IF (NARGS.GT.6) THEN
	#          ENDIF
	#          IF (NARGS.GT.7) THEN
	#          ENDIF
		$self->shiftvars(qw( PARAM1 PARAM2 PARAM3 PARAM4 PARAM5 PARAM6 PARAM7 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PARAMS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PATCHYD" ){
		$self->vars("PATCHYDT" => 1);
		$self->vars("RBAAT" => 1);
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          ALLOCATE(RBSTLA(NRBSITES,3))
	#          CALL DEFPATCHES
	#          NTSITES = NATOMS*NRBSITES/2
	# 
	# !
	# !  PATH specifies calculation of the pathway connecting two minima from the transition
	# !  state specified in odata. NPATHFRAME is the number of points files to save on either
	# !  side. A complete xyz file is printed to path.xyz and the energy as a function of
	# !  path length is printed to file EofS.
	# !  Movies generated in this way tend to move too fast for the interesting bits, and too
	# !  slow around stationary points. Specify FRAMEEDIFF to give a lower bound to the energy difference
	# !  between frames for which the structure is considered different.
	# !
	# 
		$self->shiftvars(qw( NRBSITES ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PATCHYD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PATH" ){
		$self->vars("PATHT" => 1);
	#          IF (NARGS.GT.1) THEN
	# !             if (NPATHFRAME<3) THEN
	# !                  PRINT *, 'Number of path frames cannot be less than 3 - stop'
	# !                  stop
	# !             ELSE IF (NPATHFRAME>3) THEN
	# !                  IF (.NOT.PRINTPTS) THEN
	# !                       PRINT *, 'Number of path frames is more than 3 - dumping all points!'
	# !                       PRINTPTS=.TRUE.
	# !                  ENDIF
	# !             ENDIF
	# 
	#          ENDIF
	#          IF (NPATHFRAME.LE.0) PRINTPTS=.FALSE.
	#          IF (NPATHFRAME.GT.0) PRINTPTS=.TRUE.
		$self->shiftvars(qw( NPATHFRAME FRAMEEDIFF ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PATH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PERMDIHE" ){
	# !
	# !  PATHSDSTEPS sets the number of SD steps allowed at the beginning of a path
	# !  calculation. We switch to LBFGS from RKMIN, BSMIN and SEARCH INR methods if
	# !  they don't converge in PATHSDSTEPS steps. If not set then the default is NSTEPS.
	# !
	# 
	}
	elsif($kw eq "PATHSDSTEPS" ){
		$self->shiftvars(qw( PATHSDSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PATHSDSTEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PERMDIHE" ){
		$self->vars("PERMDIHET" => 1);
	#          DO J1=1,NARGS-1
	#             PERMDIHE(J1)=NDUM
	#          ENDDO
	#          NPERMDIHE=NARGS-1
	#          DO J1=1,NARGS-1
	#             PRINT *,'PERMDIHE',PERMDIHE(J1)
	#          ENDDO
	# !
	# !  Whether to optimise the permutational isomers in assessing optimal
	# !  alignment.
	# !
	# 
	#       ELSE IF ((WORD.EQ.'PERMDIST').OR.(WORD.EQ.'PERMDISTINIT').OR.(WORD.EQ.'LOCALPERMDIST')) THEN
		$self->vars("PERMDIST" => 1);
	#          IF (WORD.EQ.'PERMDISTINIT') PERMDISTINIT=.TRUE.
	#          IF (WORD.EQ.'LOCALPERMDIST') THEN
		$self->vars("LOCALPERMDIST" => 1);
	#             PRINT '(A)',' keyword> Local rigid body permutational alignment:'
	#             PRINT '(2(A,F12.4),A,I6)','          distance tolerance=',LPDGEOMDIFFTOL,' cutoff=',RBCUTOFF, &
	#      &                  ' number of passes through alignment phase=',NRBTRIES
	#          ENDIF
	#          INQUIRE(FILE='perm.allow',EXIST=PERMFILE)
	#          IF (PERMFILE) THEN
	#             OPEN(UNIT=1,FILE='perm.allow',STATUS='OLD')
	#             READ(1,*) NPERMGROUP
	# !           ALLOCATE(NPERMSIZE(NATOMS),PERMGROUP(NATOMS),NSWAP(NATOMS),SWAP1(NATOMS,3),SWAP2(NATOMS,3))
	# 
	#             ALLOCATE(NPERMSIZE(3*NATOMS),PERMGROUP(3*NATOMS),NSETS(3*NATOMS),SETS(NATOMS,3))
	# !
	# !  The above dimensions were fixed at NATOMS because:
	# !  (a) Atoms were not allowed to appear in more than one group.
	# !  (b) The maximum number of pair exchanges associated with a group is three.
	# !
	# ! However, for flexible water models we need to exchange all waters,
	# ! and we can exchange H's attached to the same O. The dimension required
	# ! becomes 3*NATOMS
	# !
	# 
	#             NDUMMY=1
	#             DO J1=1,NPERMGROUP
	#                READ(1,*) NPERMSIZE(J1),NSETS(J1)
	# !
	# !  Sanity checks!
	# !
	# 
	#                IF (NSETS(J1).GT.3) THEN
	#                   PRINT '(2(A,I8))','keyword> ERROR - number of secondary sets ',NSETS(J1),' is > 3'
	#                   STOP
	#                ENDIF
	# !              IF (NDUMMY+NPERMSIZE(J1)-1.GT.NATOMS) THEN
	# 
	#                IF (NDUMMY+NPERMSIZE(J1)-1.GT.3*NATOMS) THEN
	#                   PRINT '(2(A,I8))','keyword> ERROR - number of atoms to be permuted in all groups is > 3*number of atoms'
	#                   STOP
	#                ENDIF
	# !              READ(1,*) PERMGROUP(NDUMMY:NDUMMY+NPERMSIZE(J1)-1),((SETS(PERMGROUP(J3),J2),J2=1,NSETS(J1)),
	# !    &                                                            J3=NDUMMY,NDUMMY+NPERMSIZE(J1)-1)
	# 
	#                READ(1,*) PERMGROUP(NDUMMY:NDUMMY+NPERMSIZE(J1)-1),((SETS(PERMGROUP(J3),J2),J3=NDUMMY,NDUMMY+NPERMSIZE(J1)-1), &
	#      &                                                              J2=1,NSETS(J1))
	#                NDUMMY=NDUMMY+NPERMSIZE(J1)
	#             ENDDO
	# !
	# !  And another sanity check! This condition is now allowed.
	# !
	# !           DO J1=1,NDUMMY
	# !              DO J2=J1+1,NDUMMY
	# !                 IF (PERMGROUP(J2).EQ.PERMGROUP(J1)) THEN
	# !                    PRINT '(2(A,I8))','keyword> ERROR - atom ',PERMGROUP(J1),' appears more than once'
	# !                    STOP
	# !                 ENDIF
	# !              ENDDO
	# !           ENDDO
	# 
	#             CLOSE(1)
	# !
	# !  And yet another!
	# !
	# 
	#             IF (NFREEZE.GT.0) THEN
	#                NDUMMY=0
	#                DO J1=1,NPERMGROUP
	#                   DO J2=1,NPERMSIZE(J1)
	#                      IF (FROZEN(PERMGROUP(NDUMMY+J2))) THEN
	#                         PRINT '(A,I8,A)',' keyword> ERROR atom ',PERMGROUP(NDUMMY+J2),' cannot be frozen and permuted'
	#                         STOP
	#                      ENDIF
	#                   ENDDO
	#                   NDUMMY=NDUMMY+NPERMSIZE(J1)
	#                ENDDO
	#             ENDIF
	#          ELSE
	#             ALLOCATE(NPERMSIZE(NATOMS),PERMGROUP(NATOMS),NSETS(NATOMS),SETS(NATOMS,2))
	#             NSETS(1:NATOMS)=0
	#             NPERMGROUP=1 ! all atoms can be permuted - default
	#             NPERMSIZE(1)=NATOMS ! all atoms can be permuted - default
	#             IF (RBAAT) NPERMSIZE(1)=NATOMS/2 ! for rigid bodies
	#             DO J1=1,NPERMSIZE(1)
	#                PERMGROUP(J1)=J1
	#             ENDDO
	#          ENDIF
	#          PRINT '(A,I6)',' keyword> Number of groups of permutable atoms=',NPERMGROUP
	#          NDUMMY=1
	#          IF (DEBUG) THEN
	#             DO J1=1,NPERMGROUP
	#                PRINT '(A,3(I6,A))',' keyword> group ',J1,' contains ',NPERMSIZE(J1),' atoms with ', &
	#      &                                                    NSETS(J1),' additional atom sets:'
	#                WRITE(*,'(22I6)',ADVANCE='NO') PERMGROUP(NDUMMY:NDUMMY+NPERMSIZE(J1)-1)
	#                IF (NSETS(J1).GT.0) THEN
	#                   WRITE(*,'(A)',ADVANCE='NO') ' with '
	#                   DO J2=1,NSETS(J1)
	#                      DO J3=NDUMMY,NDUMMY+NPERMSIZE(J1)-1
	#                         WRITE(*,'(I6)',ADVANCE='NO') SETS(PERMGROUP(J3),J2)
	#                         IF (J3.LT.NDUMMY+NPERMSIZE(J1)-1) WRITE(*,'(A3)',ADVANCE='NO') ' / '
	#                      ENDDO
	#                      IF (J2.LT.NSETS(J1)) WRITE(*,'(A3)',ADVANCE='NO') ' ; '
	#                   ENDDO
	#                ENDIF
	#                PRINT *,' '
	#                NDUMMY=NDUMMY+NPERMSIZE(J1)
	#             ENDDO
	#          ENDIF
	# !
	# !  CHARMM and UNRES dihedral angle perturbation specification.
	# !  Performs random, {\tt GMIN}-style twists before starting optimisation.
	# !
	# 
	# 
		$self->shiftvars(qw( NDUM LPDGEOMDIFFTOL RBCUTOFF NRBTRIES ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PERMDIHE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PERTDIHE" ){
		$self->vars("PERTDIHET" => 1);
	#          CHPMIN=CHPMAX
	# !        PRINT *,'CHPMIN,CHPMAX,CHNMIN,CHNMAX',CHPMIN,CHPMAX,CHNMIN,CHNMAX
	# 
	# !
	# !  SQVV keyword.
	# !
	# 
		$self->shiftvars(qw( CHPMAX CHNMIN CHNMAX ISEED ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PERTDIHE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PRINTOPTIMIZETS" ){
	#           PRINTOPTIMIZETS=.TRUE.
	# !
	# !  For the GS and ES double-ended transition state
	# !  search methods, if using {\it FIXATMS\/} to zero some coordinates of the
	# !  forces to avoid overall translation and rotation, this keyword will rotate
	# !  the start and end points so that those coordinates are zero in both.
	# !
	# 
	}
	elsif($kw eq "PREROTATE" ){
	#          PREROTATE = .TRUE.
	# !
	# !
	# !  PRESSURE tells the program to perform a constant pressure optimisation
	# !           for SC, ME and P6 with periodic boundary conditions - default off
	# !
	# 
	}
	elsif($kw eq "PRESSURE" ){
		$self->vars("PRESSURE" => 1);
	# !
	# !  PRINT n sets the value of IPRNT                              - default n=0
	# !
	# 
	}
	elsif($kw eq "PRINT" ){
	# !
	# !  Print ground state coefficients - only valid for MSEVB potential
	# !
	# 
		$self->shiftvars(qw( IPRNT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PRINT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PRINTCOEFFICIENTS" ){
	#          printCoefficients=.TRUE.
	# 
	# ! print out info on coordinates and stop; for debugging internals
	# 
	}
	elsif($kw eq "PRINTCOORDS" ){
		$self->vars("PRINTCOORDS" => 1);
	# !
	# !
	# !
	# !
	# !  Keyword for applied static force.
	# !
	# 
	}
	elsif($kw eq "PULL" ){
		$self->vars("PULLT" => 1);
	#          IF (PFORCE.EQ.0.0D0) THEN
	#             WRITE(*,'(A,I6,A,I6,A,G20.10)') ' keyword> WARNING *** Pulling force is zero, turning off pulling directive'
		$self->vars("PULLT" => 0);
	#          ELSE
	#             WRITE(*,'(A,I6,A,I6,A,G20.10)') ' keyword> Pulling atoms ',PATOM1,' and ',PATOM2,' force=',PFORCE
	#          ENDIF
	# !
	# !  PUSHCUT sets the threshold for when a PUSHOFF will be applied, i.e.
	# !  the RMS force must be less than PUSHCUT.
	# !
	# 
		$self->shiftvars(qw( PATOM1 PATOM2 PFORCE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PULL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PUSHCUT" ){
	# !
	# !  PUSHOFF x sets the magnitude of the step away from a converged
	# !            transition state if detected on the first cycle of
	# !            a minimisation                                     - default x=0.01
	# !
	# 
		$self->shiftvars(qw( PUSHCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PUSHCUT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PUSHOFF" ){
	# !
	# !  PV
	# !
	# 
		$self->shiftvars(qw( PUSHOFF ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PUSHOFF => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PV" ){
		$self->vars("PV" => 1);
		$self->shiftvars(qw( PRESS PVCONV PVTOL PVSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PV => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PVTS" ){
		$self->vars("PV" => 1);
		$self->vars("PVTS" => 1);
	#          NBOXTS=1
	#          WRITE(*,'(A,I5)') ' Searching uphill for a transition state in box length coordinate ',NBOXTS
		$self->shiftvars(qw( PRESS PVCONV PVTOL PVSTEPS NBOXTS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PVTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PYG" ){
	#          NRBSITES = 1
	#          ALLOCATE(RBSITE(NRBSITES,3))
		$self->vars("PYGT" => 1);
		$self->vars("RBAAT" => 1);
	#          IF (PYA1(1) == PYA2(1) .AND. PYA1(2) == PYA2(2) .AND. PYA1(3) == PYA2(3)) THEN
		$self->vars("RADIFT" => 0);
	#          ELSE
		$self->vars("RADIFT" => 1);
	#          ENDIF
	# ! sf344> PY potential and extra LJ site
	# 
		$self->shiftvars(qw( PYSIGNOT PYEPSNOT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PYG => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "PYBINARY" ){
	#          NRBSITES = 1
	#          ALLOCATE(RBSITE(NRBSITES,3))
		$self->vars("PYBINARYT" => 1);
		$self->vars("ANGLEAXIS2" => 1);
		$self->vars("RBAAT" => 1);
		$self->vars("RADIFT" => 1);
	#          IF(.NOT.ALLOCATED(PYA1bin)) ALLOCATE(PYA1bin(NATOMS/2,3))
	#          IF(.NOT.ALLOCATED(PYA2bin)) ALLOCATE(PYA2bin(NATOMS/2,3))
	#          DO J1=1,NATOMS/2
	#           IF(J1<=PYBINARYTYPE1) THEN
	#            PYA1bin(J1,:)=PYA11(:)
	#            PYA2bin(J1,:)=PYA21(:)
	#           ELSE
	#            PYA1bin(J1,:)=PYA12(:)
	#            PYA2bin(J1,:)=PYA22(:)
	#           END IF
	#          END DO
		$self->shiftvars(qw( PYBINARYTYPE1 PYSIGNOT PYEPSNOT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PYBINARY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "CLOSESTALIGNMENT" ){
		$self->vars("CLOSESTALIGNMENT" => 1);
	#          WRITE(*,*) 'Putting structures into closest alignment, then exiting'
	}
	elsif($kw eq "PYGPERIODIC" ){
		$self->vars("PYGPERIODICT" => 1);
		$self->vars("ANGLEAXIS2" => 1);
		$self->vars("RBAAT" => 1);
	#          IF(.NOT.ALLOCATED(PYA1bin)) ALLOCATE(PYA1bin(NATOMS/2,3))
	#          IF(.NOT.ALLOCATED(PYA2bin)) ALLOCATE(PYA2bin(NATOMS/2,3))
	#          DO J1=1,NATOMS/2
	#            PYA1bin(J1,:)=PYA1(:)
	#            PYA2bin(J1,:)=PYA2(:)
	#          END DO
	#          IF (PYA1(1) == PYA2(1) .AND. PYA1(2) == PYA2(2) .AND. PYA1(3) == PYA2(3)) THEN
		$self->vars("RADIFT" => 0);
	#          ELSE
		$self->vars("RADIFT" => 1);
	#          ENDIF
	#          IF (NARGS.GT.9) THEN
		$self->vars("PARAMONOVCUTOFF" => 1);
	#             PCUTOFF=PCUTOFF*PYSIGNOT
	#             write (MYUNIT,*) "PY Potential. PCutoff ON:",PCUTOFF
	#          ENDIF
	#          IF (NARGS.GT.10) THEN
	# ! control which dimensions have periodic boundaries with a string 'XYZ', always put x before y before z.
	# ! eg ...  Xz 20 30  specifies PBC on X and Z directions.  The X box size will be 20, the Z box size 30
	# 
	#             write (*,*) "PBCs are: ",PBC
	#             BOXLX=0
	#             BOXLY=0
	#             BOXLZ=0
	#             IF (SCAN(PBC,'Xx').NE.0) THEN
		$self->vars("PARAMONOVPBCX" => 1);
	#                 CALL READF(BOXLX)       ! BOXLX is a scaling factor, not the actual box length!
	#                 BOXLX=BOXLX*PCUTOFF     ! now BOXLX is the actual box length
	#                 write(*,*) "PY Periodic Boundary Condition X active. BOXLX:",BOXLX
	#             ENDIF
	#             IF (SCAN(PBC,'Yy').NE.0) THEN
		$self->vars("PARAMONOVPBCY" => 1);
	#                 BOXLY=BOXLY*PCUTOFF
	#                 write(*,*) "PY Periodic Boundary Condition Y active. BOXLY:",BOXLY
	#             ENDIF
	#             IF (SCAN(PBC,'Zz').NE.0) THEN
		$self->vars("PARAMONOVPBCZ" => 1);
	#                 BOXLZ=BOXLZ*PCUTOFF
	#                 write(*,*) "PY Periodic Boundary Condition Z active. BOXLZ",BOXLZ
	#             ENDIF
	#          ENDIF
	#          ALLOCATE(RBSITE(NRBSITES,3))
	# !
	# !  QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	# !
	# !
	# !  qSPCFw  flexible water model introduced by Paesani et al. (JCP 125, 184507 (2006))
	# !  Coded by Javier.
	# !
	# 
		$self->shiftvars(qw( PYSIGNOT PYEPSNOT PCUTOFF PBC BOXLY BOXLZ ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( PYGPERIODIC => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "QSPCFW" ){
		$self->vars("QSPCFWT" => 1);
	# !
	# !  qTIP4PF flexible water model introduced by Habershon et al. (JCP 131, 024501 (2009))
	# !  Coded by Javier.
	# !
	# 
	}
	elsif($kw eq "QTIP4PF" ){
		$self->vars("QTIP4PFT" => 1);
	# !
	# !  RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
	# !
	# !
	# !  Spherical container
	# !
	# 
	}
	elsif($kw eq "RADIUS" ){
		$self->vars("CONTAINER" => 1);
	#          RADIUS=RADIUS**2
	# !
	# !  integer seed for random number generator.
	# !
	# 
		$self->shiftvars(qw( RADIUS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( RADIUS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RANSEED" ){
	#          CALL SDPRND(NDUM)
	#          IF ((NDUM.LT.0).OR.(NDUM.GT.9999)) THEN
	# !
	# !  if we ever need more than 20000 searches from the same minimum
	# !  then this could be a problem
	# !
	# 
	#             DO J1=1,3*NATOMS
	#                 RANDOM=DPRAND()
	#             ENDDO
	#          ENDIF
	#          WRITE(*,'(A,I6)') ' SETTINGS Random number generator seed=',NDUM
	# !
	# !  TVB: Requests to print out pathway parameters necessary to calculate catastrophe
	# !  ratios. Affects path routine only.
	# !
	# 
		$self->shiftvars(qw( NDUM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( RANSEED => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RATIOS" ){
		$self->vars("RATIOS" => 1);
	# !
	# !  RBSYM defines the internal symmetry operations for each sort of rigid body
	# !  coded via RBAAT.
	# !
	# 
	}
	elsif($kw eq "RBSYM" ){
		$self->vars("RBSYMT" => 1);
	#          INQUIRE(FILE='rbsymops',EXIST=RBSYMTEST)
	#          IF (RBSYMTEST) THEN
	#             OPEN(UNIT=1,FILE='rbsymops',STATUS='OLD')
	#             READ(1,*) NRBGROUP
	#             ALLOCATE(RBOPS(4,NRBGROUP))
	#             READ(1,*) ((RBOPS(J1,J2),J1=1,4),J2=1,NRBGROUP)
	#             PRINT '(A,I6)',' keywords> number of symmetry operations for rigid body=',NRBGROUP
	#             DO J1=1,NRBGROUP
	#                PRINT '(A,I6)',' keywords> rigid-body symmetry operation', J1
	#                RBOPS(4,J1) = RBOPS(4,J1)*ATAN(1.D0)/45.D0
	#                PRINT '(3F20.10)',RBOPS(1:4,J1)
	#             ENDDO
	#          ELSE
	#             PRINT '(A)',' keywords> ERROR *** missing file rbsymops'
	#             STOP
	#          ENDIF
	# !
	# !  If READPATH is specified with CALCRATES then the rates are calculated from the
	# !  information in an existing path.info file without any stationary point searches.
	# !
	# 
	}
	elsif($kw eq "READPATH" ){
		$self->vars("READPATH" => 1);
	# !
	# !  If READSP is true then OPTIM will read minima and ts data in the pathsample format
	# !
	# 
	}
	elsif($kw eq "READSP" ){
		$self->vars("READSP" => 1);
	# !
	# !  READHESS tells the program to read a Hessian at the first step.
	# !
	# 
	}
	elsif($kw eq "READHESS" ){
		$self->vars("READHESS" => 1);
	# !
	# !  READVEC "file" reads the eigenvalue and associated eigenvector corresponding
	# !  to the reaction coordinate for use in a pathway calculation. The format
	# !  is the same as that used for vector.dump. If there is more than one vector
	# !  in the file the program reads down to the last entry.
	# !
	# 
	#       ELSE IF (WORD(1:7) .EQ. 'READVEC') THEN
		$self->vars("READV" => 1);
	# !     ELSE IF (WORD.EQ.'REBUILDSC') THEN
	# !        CALL READF(REBUILDSC)
	# !
	# !  sf344> read in coordinates from path.xyz files for rigid bodies, and
	# !         bring the frames in the best alignment
	# !
	# 
	}
	elsif($kw eq "REALIGNXYZ" ){
		$self->vars("REALIGNXYZ" => 1);
	# !
	# !  Whether to use a redopoints file if it exists.
	# !
	# 
	}
	elsif($kw eq "REDOPATH" ){
		$self->vars("REDOPATH" => 1);
	# !
	# !  Whether to use a redopoints file if it exists.
	# !
	# 
		$self->shiftvars(qw( REDOK REDOFRAC ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( REDOPATH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "REDOPATHNEB" ){
		$self->vars("REDOPATHNEB" => 1);
		$self->vars("REDOPATH" => 1);
		$self->vars("FREEZENODEST" => 1);
	#          FREEZETOL=-1.0D0
	# !
	# !  Whether to use path.<n>.xyz files in the current directory
	# !
	# 
		$self->shiftvars(qw( REDOBFGSSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( REDOPATHNEB => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "REDOPATHXYZ" ){
		$self->vars("REDOPATHXYZ" => 1);
		$self->vars("REDOPATH" => 1);
	# !
	# ! Whether to reduce the bond lengths for side chains during the connection runs.
	# ! To be used together with CHARMM (and AMBER not yet).
	# !
	# 
		$self->shiftvars(qw( REDOK REDOFRAC ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( REDOPATHXYZ => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "REDUCEDBONDLENGTH" ){
		$self->vars("REDUCEDBONDLENGTHT" => 1);
	#          IF (TRIM(ADJUSTL(UNSTRING)).EQ.'CB') CBT=.TRUE.
	# !
	# !  Specifies that the eigenvector to be followed should be reoptimised
	# !  in a BFGSTS search after the EF step and before the tangent space minimisation.
	# !  This is probably not a good idea.
	# !
	# 
		$self->shiftvars(qw( BLFACTOR UNSTRING ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( REDUCEDBONDLENGTH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "REOPT" ){
		$self->vars("REOPT" => 1);
	}
	elsif($kw eq "REOPTIMISEENDPOINTS" ){
		$self->vars("REOPTIMISEENDPOINTS" => 1);
	# !
	# !  coordinates to orthogonalise search directions to are to be found in
	# !  points.repel
	# !
	# 
	}
	elsif($kw eq "REPELTS" ){
		$self->vars("REPELTST" => 1);
	# !
	# !  RESIZE x scales the radial distances by x on the first
	# !           step only                                           - default n=1
	# !
	# 
		$self->shiftvars(qw( REPELPUSH ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( REPELTS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RESIZE" ){
	# 
	# ! specifies additional rings other than the usual ones in
	# ! PHE, PRO, TYR, HIS, and TRP residues
	# 
		$self->shiftvars(qw( RESIZE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( RESIZE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RING" ){
	#          NURINGS = NURINGS + 1
	#          IF (NARGS.EQ.6) THEN
	#             URINGS(NURINGS,0) = 5
	#             DO J1 = 1,5
	#             ENDDO
	#          ELSE IF (NARGS.EQ.7) THEN
	#             URINGS(NURINGS,0) = 6
	#             DO J1 = 1,6
	#             ENDDO
	#          ENDIF
	# !
	# !  RINGPOLYMER specifies a ring polymer system with harmonic springs between
	# !  NRP images of the same system that generally have different geometries.
	# !  RPSYSTEM is a string specifying the system, e.g. LJ.
	# !  RPIMAGES is the number of RP images.
	# !  RPBETA is 1/kT in reduced units.
	# !  RINGPOLYMER keyword takes the place of POINTS and must be the last
	# !  keyword in the odata file before the points.
	# !
	# 
	}
	elsif($kw eq "RINGPOLYMER" ){
		$self->vars("RINGPOLYMERT" => 1);
	# !
	# !  Sanity checks.
	# !
	# 
	#          TEMPSTRING=TRIM(ADJUSTL(RPSYSTEM))
	#          IF (TEMPSTRING(1:2).EQ.' ') THEN
	#             PRINT '(A)','keyword> ERROR *** Ring polymer potential type is not set'
	#          ENDIF
	#          IF (RPIMAGES.LT.1) THEN
	#             PRINT '(A)','keyword> ERROR *** Ring polymer images too small, value is ',RPIMAGES
	#          ENDIF
	#          RETURN
	# !
	# !  RKMIN calculates a steepest-descent path using gradient only information
	# !  with convergence criterion GMAX for the RMS force and initial precision
	# !  EPS. A fifth order Runga-Kutta algorithm is used.
	# !
	# 
		$self->shiftvars(qw( RPSYSTEM RPIMAGES RPBETA ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( RINGPOLYMER => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RKMIN" ){
		$self->vars("RKMIN" => 1);
	# !
	# !  ROT [JZ n or OMEGA n] sets the value of J_z, the angular
	# !                          momentum about the z axis or
	# !                          OMEGA, the corresponding angular velocity
	# !
	# 
		$self->shiftvars(qw( GMAX EPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( RKMIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ROT" ){
		$self->vars("RTEST" => 1);
	#         IF (WORD.EQ.'JZ') THEN
	#            JZ=XX
	#         ELSE
	#            OMEGA=XX
	#         ENDIF
	# !
	# ! fix linear polymer at its ends
	# !
	# 
		$self->shiftvars(qw( WORD XX ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ROT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "RPFIX" ){
		$self->vars("RPFIXT" => 1);
	#          print *, 'fixed ends'
	# !
	# ! make ring polymer system into linear polymer
	# !
	# 
	}
	elsif($kw eq "RPLINEAR" ){
		$self->vars("RPCYCLICT" => 0);
	#          print *, 'use linear polymer'
	# !
	# !  SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
	# !
	# !
	# !  Save candidate TS`s in SQVV run.
	# !
	# 
	}
	elsif($kw eq "SAVECANDIDATES" ){
	#           SAVECANDIDATES=.TRUE.
	# !
	# !  SCALE n sets the value of ISTCRT                             - default n=10
	# !
	# 
	}
	elsif($kw eq "SCALE" ){
	# !
	# !  Specify that we are running in a SCore environment. Currently never used.
	# !
	# 
		$self->shiftvars(qw( ISTCRT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SCALE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SCORE_QUEUE" ){
		$self->vars("SCORE_QUEUE" => 1);
	# !
	# !  SEARCH specifies the value of INR, i.e. the search type.     - default n=0
	# !
	# 
	}
	elsif($kw eq "SEARCH" ){
	# !
	# !  Eigenvalue shift parameter.
	# !
	# 
		$self->shiftvars(qw( INR ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SEARCH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SHIFT" ){
	# !
	# !  Parameters for Edwin;s SiO2 model
	# !
	# 
		$self->shiftvars(qw( SHIFTV ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SHIFT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SIO2" ){
		$self->vars("SIO2T" => 1);
	#          IF (NARGS.GT.2) THEN
	#          ENDIF
	#          IF (NARGS.GT.3) THEN
	#          ENDIF
	#          IF (NARGS.GT.4) THEN
	#          ENDIF
		$self->shiftvars(qw( PARAM1 PARAM2 PARAM3 PARAM4 ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SIO2 => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SIO2C6" ){
		$self->vars("SIO2C6T" => 1);
	# !
	# !  SQVV allows the first NIterSQVVGuessMax DNEB iterations to be done using
	# !  SQVV - switches to LBFGS minimisation after NIterSQVVGuessMax iterations
	# !         or if the RMS force goes below SQVVGuessRMSTol.
	# !
	# 
		$self->shiftvars(qw( C6PP C6MM C6PM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SIO2C6 => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SQVV" ){
	#          SQVVGUESS=.TRUE.
	# !
	# !  NSTEPMIN sets the minimum number of steps allowed before convergence.
	# !
	# 
		$self->shiftvars(qw( NITERSQVVGUESSMAX SQVVGUESSRMSTOL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SQVV => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STEPMIN" ){
	# !
	# !  STEPS n sets the number of optimisation steps to perform
	# !          per call to OPTIM                                    - default n=1
	# !  If BFGSSTEPS is not specified then it is set to the same value as NSTEPS
	# !
	# 
		$self->shiftvars(qw( NSTEPMIN ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( STEPMIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STEPS" ){
	#         IF (BFGSSTEPS.EQ.1) BFGSSTEPS=NSTEPS
	# !
	# !  Stillinger-David water potential - coded by Jeremy Richardson
	# !
	# 
		$self->shiftvars(qw( NSTEPS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( STEPS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SD" ){
		$self->vars("SDT" => 1);
	#          IF (SDOXYGEN*SDHYDROGEN.EQ.0) THEN
	#             PRINT '(A,2I6)', ' keyword> ERROR *** number of SD oxygens and hydrogens=',SDOXYGEN,SDHYDROGEN
	#             STOP
	#          ENDIF
		$self->shiftvars(qw( SDOXYGEN SDHYDROGEN SDCHARGE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STOCK" ){
		$self->vars("STOCKT" => 1);
	# !        RIGIDBODY=.TRUE.
	# !        NRBSITES=1 ! used in current GMIN
	# 
	# !        ALLOCATE(SITE(NRBSITES,3))
	# !
	# !    STOCKSPIN randomises the orientation of a Stockmayer cluster at any point in
	# !    an optimisation where a dipole vector becomes aligned with the z axis (which
	# !    make the phi angle for that dipole redundant).  STOCKZTOL is the amount by
	# !    which cos(theta) may differ from 1.0 for alignment to be recognised.
	# !    STOCKMAXSPIN is the maximum number of random orientations that will be attempted.
	# !
	# 
		$self->shiftvars(qw( STOCKMU STOCKLAMBDA ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( STOCK => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STOCKSPIN" ){
		$self->vars("STOCKSPIN" => 1);
	# !
	# !  STOPDIST specifies an alternative stopping criterion based on displacement
	# !  between the first or last minimum and the furthest connected minimum.
	# !
	# 
		$self->shiftvars(qw( STOCKZTOL STOCKMAXSPIN ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( STOCKSPIN => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ST" ){
		$self->vars("STOCKAAT" => 1);
		$self->vars("RBAAT" => 1);
	#          IF (NARGS .GT. 2) THEN
		$self->vars("EFIELDT" => 1);
	#          ENDIF
	#          NRBSITES = 1
	#          ALLOCATE(RBSITE(NRBSITES,3))
	#          NTSITES = NATOMS*NRBSITES/2
		$self->shiftvars(qw( STOCKMU EFIELD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( ST => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STOPDISP" ){
	#          STOPDISPT=.TRUE.
	# !
	# !  In a CONNECT run, stop as soon as the initial minimum has a transition state
	# !  connection.
	# !
	# 
		$self->shiftvars(qw( STOPDISP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( STOPDISP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "STOPFIRST" ){
		$self->vars("STOPFIRST" => 1);
	# !
	# !  SUMMARY n print a summary of the steps taken every n cycles  - default n=20
	# !
	# 
	}
	elsif($kw eq "SUMMARY" ){
	# !
	# !  SYMCUT n RMS force below which symmetry subroutine is called - default 0.001
	# !
	# 
		$self->shiftvars(qw( NSUMMARY ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SUMMARY => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "SYMCUT" ){
	# !
	# !  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
	# !
	# !
	# !  Tagged particle - atom in question has mass increased by TAGFAC in symmetry.f and inertia.f
	# !
	# 
		$self->shiftvars(qw( SYMCUT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( SYMCUT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TAG" ){
		$self->vars("TAGT" => 1);
	#          NTAG=NTAG+1
	}
	elsif($kw eq "TANTYPE" ){
	#          GSTANTYPE = TANTYPE
	# !
	# !  Add a tetrahedral field to the potential of magnitude FTD.
	# !
	# 
		$self->shiftvars(qw( TANTYPE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TANTYPE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TD" ){
		$self->vars("FIELDT" => 1);
		$self->vars("TDT" => 1);
	# !
	# !  TIMELIMIT - in seconds - OPTIM will stop if this limit is exceeded.
	# !
	# 
		$self->shiftvars(qw( FTD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TIMELIMIT" ){
	# !
	# !  TOLD n initial distance tolerance in symmetry subroutine     - default 0.0001
	# !
	# 
		$self->shiftvars(qw( TIMELIMIT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TIMELIMIT => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TOLD" ){
	# !
	# !  TOLE n initial tolerance for the difference in principal moments
	# !         of inertia divided by the sum of the principal moments
	# !         in symmetry subroutine                                - default 0.0001
	# !
	# 
		$self->shiftvars(qw( TOLD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TOLD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TOLE" ){
	# !
	# !  Includes omega angles in the TWISTDIHE list.
	# !
	# 
		$self->shiftvars(qw( TOLE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TOLE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TOMEGA" ){
		$self->vars("TOMEGAC" => 1);
	}
	elsif($kw eq "TOSIPOL" ){
		$self->vars("TOSIPOL" => 1);
	#          WRITE(*,'(A)') ' Polarizabilities:'
	#          WRITE(*,'(A,F12.8,A,F12.8)') ' alpha+=',ALPHAP,' alpha-=',ALPHAM
	#          WRITE(*,'(A,F12.8,A)') ' damping coefficent=',DAMP,' per bohr'
	# !
	# !  TRAD n sets the trust radius to n                            - default n=4
	# !
	# 
		$self->shiftvars(qw( ALPHAP ALPHAM DAMP ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TOSIPOL => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TRAD" ){
	# !
	# !  TRAP is used for the trap potential in EYtrap coded by Ersin Yurtsever.
	# !
	# 
		$self->shiftvars(qw( TRAD ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TRAD => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TRAP" ){
		$self->vars("EYTRAPT" => 1);
	# !
	# !  Includes sidechain angles in the TWISTDIHE list.
	# !
	# 
		$self->shiftvars(qw( TRAPK NTRAPPOW ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TRAP => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TSIDECHAIN" ){
		$self->vars("TSIDECHAIN" => 1);
	# !
	# !  Twist phi/psi dihedral angle nmode by xpert degrees before starting optimisation.
	# !
	# 
	}
	elsif($kw eq "TWISTDIHE" ){
		$self->vars("TWISTDIHET" => 1);
	# !
	# !  TWISTTYPE specifies the type of twisting done to guess transition states in GUESSTS for CHARMM
	# !
	# 
		$self->shiftvars(qw( DMODE DPERT ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TWISTDIHE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TWISTTYPE" ){
	# !
	# !  Double ended ts search.
	# !
	# 
		$self->shiftvars(qw( TWISTTYPE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TWISTTYPE => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "TWOENDS" ){
		$self->vars("TWOENDS" => 1);
	# !
	# !  UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
	# !
	# 
	# 
		$self->shiftvars(qw( FSTART FINC NTWO RMSTWO NTWOITER TWOEVAL ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( TWOENDS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "UNIAX" ){
		$self->vars("UNIAXT" => 1);
	}
	elsif($kw eq "UNRES" ){
		$self->vars("UNRST" => 1);
	# !CALL UNRESINIT
	# ! CALPHAS AND THE SIDE CHAIN CENTROIDS ARE COUNTED AS ATOMS, BUT NOT THE PEPTIDE BOND CENTRES.
	# 
	#          NATOM=2*NRES
	#          NATOM=2*nres
	#          IF (NATOM /= NATOMS) THEN
	#             WRITE(*,'(A)') 'No. of atoms in "coords" conflicts with that deduced from unres part of odata'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	#          NINTS=2*nres-5+2*nside ! jmc change this depending on how want to deal with non-capping glycines!
	#                                 ! jmc NINTS was previously set in fetchz, but need either it or nvaru earlier (i.e. here)
	#                                 ! so may as well set it when we first know nres and nside.
	#          IF (ENDHESS.AND.(.NOT.ENDNUMHESS)) THEN
	#             PRINT *,'**ERROR - to calculate normal mode frequencies for UNRES, please specify ENDNUMHESS keyword'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ELSEIF ((DUMPPATH.OR.DUMPALLPATHS).AND.(.NOT.ENDHESS)) THEN
	#             PRINT *,'**ERROR - to calculate normal mode frequencies for UNRES, please specify ENDHESS and ENDNUMHESS keywords'
	#             CALL FLUSH(6,ISTAT)
	#             STOP
	#          ENDIF
	# 
	# !        DO J1=1,nres
	# ! jmc c contains x,y,z for all the Calphas
	# !           UNRX(2*J1-1)=c(1,J1)
	# !           UNRY(2*J1-1)=c(2,J1)
	# !           UNRZ(2*J1-1)=c(3,J1)
	# ! jmc then x,y,z for the side chain centroids
	# !           UNRX(2*J1)=c(1,J1+nres)
	# !           UNRY(2*J1)=c(2,J1+nres)
	# !           UNRZ(2*J1)=c(3,J1+nres)
	# !        ENDDO
	# 
	# ! new read replaces random configuration coordinates with alternative from file coords
	# 
	#          CALL UNEWREAD(UNRX,UNRY,UNRZ,NATOMS,FILTH,FILTHSTR)
	#          DO J1=1,nres
	#             c(1,J1)=UNRX(2*J1-1)
	#             c(2,J1)=UNRY(2*J1-1)
	#             c(3,J1)=UNRZ(2*J1-1)
	#             c(1,J1+nres)=UNRX(2*J1)
	#             c(2,J1+nres)=UNRY(2*J1)
	#             c(3,J1+nres)=UNRZ(2*J1)
	#          ENDDO
	#          CALL UPDATEDC
	# !CALL INT_FROM_CART(.TRUE.,.FALSE.)
	# !CALL CHAINBUILD
	# ! JMC PUT COORDS IN STANDARD ORIENTATION (1ST ATOM AT 0,0,0 ETC...) INTO UNR ARRAY.  FIXES PROBLEM IN PATH,
	# ! FOR CALCULATING THE STEP OFF THE TS
	# 
	#          DO J1=1,NRES
	#             UNRX(2*J1-1)=C(1,J1)
	#             UNRY(2*J1-1)=C(2,J1)
	#             UNRZ(2*J1-1)=C(3,J1)
	#             UNRX(2*J1)=C(1,J1+NRES)
	#             UNRY(2*J1)=C(2,J1+NRES)
	#             UNRZ(2*J1)=C(3,J1+NRES)
	#          ENDDO
	#          CALL UNRSETZSYMATMASS
	#          IF (FILTH.NE.0) THEN
	#             OPEN(UNIT=20,FILE='coords.read',STATUS='REPLACE')
	#             CLOSE(20)
	#          ENDIF
	#          ALLOCATE(UREFCOORD(3*NATOMS),UREFPPSANGLE(3*NATOMS))
	#          IF (TWISTDIHET.OR.PERTDIHET.OR.GUESSTST.OR.CALCDIHE) THEN
	#             CALL UNRSETDIHE
	#          ENDIF
	#          IF (TWISTDIHET) THEN
	#             CALL UNRSTWISTDIHE(UNRX,UNRY,UNRZ,DMODE,DPERT)
	#          ENDIF
	#          IF (PERTDIHET) THEN
	#             CALL UNRSPERTDIHE(UNRX,UNRY,UNRZ,CHPMIN,CHPMAX,CHNMIN,CHNMAX,ISEED)
	#          ENDIF
	#          IF (CALCDIHE) THEN
	#             CALL UNREADREF(NATOMS)
	# ! jmc readref2 leaves reference coords in unres c and internal coord arrays, so replace with UNR{X,Y,Z} here.
	# 
	#             DO J1=1,nres
	#                c(1,J1)=UNRX(2*J1-1)
	#                c(2,J1)=UNRY(2*J1-1)
	#                c(3,J1)=UNRZ(2*J1-1)
	#                c(1,J1+nres)=UNRX(2*J1)
	#                c(2,J1+nres)=UNRY(2*J1)
	#                c(3,J1+nres)=UNRZ(2*J1)
	#             ENDDO
	#             CALL UPDATEDC
	# !CALL INT_FROM_CART(.TRUE.,.FALSE.)
	# 
	#          END IF
	#          DO J1=1,NATOMS
	#             Q(3*(J1-1)+1)=UNRX(J1)
	#             Q(3*(J1-1)+2)=UNRY(J1)
	#             Q(3*(J1-1)+3)=UNRZ(J1)
	#          ENDDO
	# !
	# ! USEDIAG enables the user to select DIAG or DIAG2 as the eigenvalue estimate in
	# ! Rayleigh-Ritz routine secdiag. Default is currently one, but two may be better!
	# !
	# 
	}
	elsif($kw eq "USEDIAG" ){
	# 
	# !
	# ! USEEV allows the lowest NUSEEV eigenvalues and associated eigenvectors to be
	# ! used in second-order searches with efol.f90.
	# !
	# 
		$self->shiftvars(qw( NSECDIAG ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( USEDIAG => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "USEEV" ){
	# !
	# !  Number of BFGS updates before resetting, default=4
	# !
	# 
		$self->shiftvars(qw( NUSEEV ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( USEEV => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "UPDATES" ){
	# !
	# !  VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
	# !
	# !
	# !  VALUES n print the Hessian eigenvalues every n cycles        - default n=20
	# !
	# 
		$self->shiftvars(qw( MUPDATE XMUPDATE MMUPDATE NEBMUPDATE INTMUPDATE GSUPDATE GCUPDATE ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( UPDATES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "VALUES" ){
	# !
	# !  VARIABLES - keyword at the end of the list of options after which
	# !           the general variables follow. NZERO is the number of zero
	# !  eigenvalues, default 0.
	# !
	# 
		$self->shiftvars(qw( NVALUES ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( VALUES => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "VARIABLES" ){
		$self->vars("VARIABLES" => 1);
	#          RETURN
	# !
	# !  VECTORS n prints the eigenvectors every n cycles             - default OFF
	# !
	# 
	}
	elsif($kw eq "VECTORS" ){
		$self->vars("VECTORST" => 1);
	# !
	# !  WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
	# !
	# 
		$self->shiftvars(qw( NVECTORS ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( VECTORS => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "WARRANTY" ){
	#           CALL WARRANTY
	# !
	# !  Welch parameters for Born-Meyer binary salt potentials.
	# !  These are A++, A--, A+- and rho, in order, followed by
	# !
	# 
	}
	elsif($kw eq "WELCH" ){
		$self->vars("WELCH" => 1);
	# !
	# !  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	# !
	# !
	# !  YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
	# !
	# !
	# !  ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
	# !
	# 
		$self->shiftvars(qw( APP AMM APM RHO XQP XQM ALPHAP ALPHAM ));
		while(@F){
			foreach($self->shiftvars){
				$self->vars( "$_" => shift @F );
				$self->chvars( WELCH => { $_ => $self->vars("$_") });
			}
		}
	}
	elsif($kw eq "ZEROS" ){
	#          ! </kwd>
	#           & &! }}}
	
	}else{
		$iskw=0;
	}
		if ($iskw){
			push(@keywords,$kw);
		}
	}
	close(F);
	
	my $ndelim=50;
	print SV "#" x $ndelim . "\n";
	print SV << "head";
	# Script name:
	#	$files{setvars}
	# Purpose:
	# 	Keyword-dependent variable assignments
	# Date: 
	# 	$date
	# Creating script:
	#	$this_script
head
	print SV "#" x $ndelim . "\n";
	
	foreach my $K (sort($self->chvars_keys)){
		print SV "# Keyword: $K\n";
		foreach(keys %{$chvars{$K}}){
			if ($self->vars_exists("$_")){
				#print SV "\$self->vars("$_" => $vars{$_};\n");
			}
		}
	}
	
	close(SV);
	}
	# }}}


sub final(){
	my $self=shift;

	if ($self->_opt_true("kw")){
		if ($self->keywords){
			$self->out("Keywords:\n");
			$self->acc_arr_print('keywords');
		}
	}

	foreach($self->vars_keys){
		$self->true_push($_) if ($self->vars("$_") && &is_log($_));
		$self->false_push($_) if (!$self->vars("$_") && &is_log($_));
	}
	
	$self->acc_arr_sortuniq("$_") for(qw(true false));
	
	# @true
	if ($self->_opt_true("true")){
		if ($self->true){
			$self->out("True logicals:\n");
			$self->acc_arr_print('true');
		}
	}

	# @false
	if ($self->_opt_true("false")){
		if ($self->false){
			$self->out("False logicals:\n");
			$self->acc_arr_print('false');
		}
	}
}


1;
