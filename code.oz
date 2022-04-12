local
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

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

   % Cette fonction fixe la durï¿½e de la partition au nombre de secondes indiquï¿½.
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
	 Factor = Second/{Sum {PartitionToTimedList Partition}}
	 {Stretch Factor Partition}
	 
      end
   end
   
   % Cette fonction ï¿½tire la durï¿½e de la partition par le facteur indiquï¿½
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
	       {Stretch Factor T2}
	       {Stretch Factor T}
	    [] silence(duration:Duration) then %peut etre pas nï¿½cessaire en pratique mais grammaire
	       H2.duration = H2.duration * Factor
	       {Stretch Factor T2}
	       {Stretch Factor T}
	    end
	 end
      end
   end
   
   % Cette fonction créer une partition comprenant la note Note un nombre Amount de fois
   fun {Drone Note Amount}
      if Amount == 0
      then nil
      else
	 case Note
	 of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    Note|{Drone Note Amount-1}
	 else then
	    {NoteToExtended Note}|{Drone Note Amount-1}
	 end
      end
   end    
	 
	 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {Transpose Semitone Partition}
      {PartitionToTimedList Partition}	 
      case Partition
      of nil then nil
      [] H|T then

	 

      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      case Partition
      of nil then nil
	 
      [] H|T then
	 case H
	 of Name#Octave then
	    H  = {NoteToExtended H}
	    {PartitionToTimedList T}
	    
	 [] Atom then
	    H = {NoteToExtended H}
	    {PartitionToTimedList T}
	 [] silence then
	    H = {NoteToExtended H}
	    
	 [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    {PartitionToTimedList T}

	 [] silence(duration:Duration) then
	    {PartitionToTimedList T}

	 [] duration(seconds:Duration Partition) then
	    H = {Duration duration.seconds {PartitionToTimedList duration.2}}
	    {PartitionToTimedList T}
	    
	 [] stretch(factor:Factor Partition) then
	    H = {Stretch stretch.factor {PartitionToTimedList stretch.2}}
	    {PartitionToTimedList T}

	 [] drone(note:Note amount:Amount) then
	    H = {Drone drone.note drone.amount} %peut etre H.note, idem pour les autres transfo 
	    {PartitionToTimedList T}
	    
	    
	    
	 [] H2|T2 then
	    case H2
	       
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       {PartitionToTimedList T}
	       
	    [] silence(duration:Duration) then %pas sï¿½re qu'il y ai besoin en pratique mais grammaire
	       {PartitionToTimedList T}

	    [] Name#Octave then
	       H2 = {NoteToExtend H2}
	       {PartitionToTimedList T2}
	       {PartitionToTimedList T}
	    [] Atom then
	       H2 = {NoteToExtend H2}
	       {PartitionToTimedList T2}
               {PartitionToTimedList T}
	    end
	 end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animals/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end