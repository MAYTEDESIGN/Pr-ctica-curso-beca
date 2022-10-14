// SPDX-License-Identifier: MIT
pragma solidity >0.8.7;



 ///@title Votacion
 //Integrantres grupo 20: Karin Alicia Reyes, Maria Teresa Batalla, Nela Berlin Gonzales, Raicelys Diaz, Zarith Fabiola Niño Castillo


contract votacion {
  // Esto declara un nuevo tipo complejo que
     // Es usado para variables más tarde.
     // Representará a un solo votante.

  
    struct Voter {
        uint weight; //El peso se acumula por delegación
        bool voted;  // si es cierto esa persona ya votó
        address delegate; // Persona delegada
        uint vote;   //  índice de la propuesta votada
    }

    // Este es un tipo para una sola propuesta.
    struct Proposal {
        string name;   // nombre corto (hasta 32 bytes)
        uint voteCount; // número de votos acumulados
    }

    address public chairperson;

    // Esto declara una variable de estado que
    // almacena una estructura `Voter` para cada dirección posible.
    mapping(address => Voter) public voters;

    // Una matriz de tamaño dinámico de estructuras `Proposal`.
    Proposal[] public proposals;

    /// Cree una nueva papeleta para elegir uno de `proposalNames`.
    constructor(string[] memory proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

      // Para cada uno de los nombres de propuesta proporcionados,
         // crear un nuevo objeto de propuesta y agregarlo
         // hasta el final de la matriz.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` crea a temporal
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) public {
       
        require(voter != chairperson, "Chairperson has default voting rights!");
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted or delegated!"
        );
        //require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) public {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

       
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        //Added for testing!
       // sender.weight += 1;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;

        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            sender.weight += 1;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(sender.weight != 0, "Voter has no voting rights!" );
        sender.voted = true;
        sender.vote = proposal;
        if (msg.sender != chairperson) {
        sender.weight += 1;
        }

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if(proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
         if(winningVoteCount == 0){
             revert("Nobody has voted yet");

         }
         for (uint x =0; x < proposals.length; x++) {
             for (uint y =x+1; y < proposals.length; y++){
                 if(winningVoteCount == proposals[x].voteCount && winningVoteCount == proposals[y].voteCount){
                     revert("This is a tie vote");
                 }
             }
         }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() public view
            returns (string memory winnerName_, uint winnerVoteCount_)
    {
        winnerName_ = proposals[winningProposal()].name;
        winnerVoteCount_ = proposals[winningProposal()].voteCount;
    }
}