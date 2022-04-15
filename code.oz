local
   %Auteur : Thomas Lamby     NOMA: 27312000        
   % See project statement for API details.
   %[Project] = {Link ['Project2022.ozf']}
   %Time = {Link ['x-oz:\\boot\Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] silence then
	 silence(duration:1.0)
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then
	    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	 [] [N O] then
	    note(name:{StringToAtom [N]}
		 octave:{StringToInt [O]}
		 sharp:false
		 duration:1.0
		 instrument: none)
	 end
      end
   end

   % Cette fonction fixe la duree de la partition au nombre de secondes indique.
   fun {Duration Second Partition}
      local Sum Factor
	 Sum =
	 fun {$ Partition N}
	    case Partition
	    of nil then
	       N
	    [] H|T then
	       case H
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  {Sum T N+H.duration}
	       [] silence(duration:Duration) then
		  {Sum T N+H.duration}
	       [] H2|T2 then
		  {Sum T N+H2.duration}
	       end
	    end
	 end
      in
	 Factor = Second/{Sum {PartitionToTimedList Partition} 0}
	 {Stretch Factor Partition}
	 
      end
   end
   
   % Cette fonction etire la duree de la partition par le facteur indique
   fun {Stretch Factor Partition}
      case Partition
      of nil then
	 nil
      [] H|T then
	 case H
	 of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    H.duration = H.duration * Factor
	    {Stretch Factor T}
	 [] silence(duration:Duration) then
	    H.duration = H.duration * Factor
	    {Stretch Factor T}
	 [] H2|T2 then
	    case H2
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       H2.duration = H2.duration * Factor
	       T2 = {Stretch Factor T2}
	       {Stretch Factor T}
	    [] silence(duration:Duration) then %peut etre pas necessaire en pratique mais grammaire
	       H2.duration = H2.duration * Factor
	       T2 = {Stretch Factor T2}
	       {Stretch Factor T}
	    end
	 end
      end
   end
   
   % Cette fonction cr�er une partition comprenant la note Note un nombre Amount de fois
   fun {Drone Note Amount}
      if Amount == 0 then
	 nil
      else
	 case Note
	 of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    Note|{Drone Note Amount-1}
	 else
	    {NoteToExtended Note}|{Drone Note Amount-1}
	 end
      end
   end    
	 
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {Transpose Semitone Partition}
      Partition = {PartitionToTimedList Partition}	 
      case Partition
      of nil then
	 nil
      [] H|T then
	 nil
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      case Partition
      of nil then
	 nil
      [] H|T then
	 case H
	 of Name#Octave then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] Atom then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] silence then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    H|{PartitionToTimedList T}

	 [] silence(duration:Duration) then
	    H|{PartitionToTimedList T}

	 [] duration(seconds:Duration Partition) then
	    {Duration duration.seconds {PartitionToTimedList duration.2}}|{PartitionToTimedList T}
	    
	 [] stretch(factor:Factor Partition) then
	    {Stretch stretch.factor {PartitionToTimedList stretch.2}}|{PartitionToTimedList T}

	 [] drone(note:Note amount:Amount) then
	    {Drone drone.note drone.amount}|{PartitionToTimedList T}
	    %peut etre H.note, idem pour les autres transfo
	    
	    
	 [] H2|T2 then
	    case H2
	       
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       H|{PartitionToTimedList T}
	       
	    [] silence(duration:Duration) then %pas sure qu'il y ai besoin en pratique mais grammaire
	       H|{PartitionToTimedList T}

	    [] Name#Octave then
	       {PartitionToTimedList H}|{PartitionToTimedList T}
	       
	    [] Atom then
	       {PartitionToTimedList H}|{PartitionToTimedList T}
	    end
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %fun {Mix P2T Music}
      % TODO
    %  {Project.readFile 'wave\animals\cow.wav'}
   %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
   %Start
   Son = [c c c#5 b b]
   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   
   {Browse {PartitionToTimedList Son}}
   
   %Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   %{ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   %{Browse {IntToFloat {Time}-Start} / 1000.0}
   
end
