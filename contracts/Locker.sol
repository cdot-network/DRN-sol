// =
pragma solidity >=0.4.22 <0.9.0;

import 'rainbow-bridge-sol/nearprover/contracts/INearProver.sol';
import 'rainbow-bridge-sol/nearprover/contracts/ProofDecoder.sol';
import 'rainbow-bridge-sol/nearbridge/contracts/NearDecoder.sol';
import 'rainbow-bridge-sol/nearbridge/contracts/Borsh.sol';

contract Locker {
    using Borsh for Borsh.Data;
    using ProofDecoder for Borsh.Data;
    using NearDecoder for Borsh.Data;

    INearProver public prover;
    bytes public nearEthFactory;

    // OutcomeReciptId -> Used
    mapping(bytes32 => bool) public usedEvents_;

    function _parseProof(
        bytes memory proofData,
        uint64 proofBlockHeight,
        bool isUsing
    ) internal returns (ProofDecoder.ExecutionStatus memory result) {
        require(prover.proveOutcome(proofData, proofBlockHeight), 'Proof should be valid');

        // Unpack the proof and extract the execution outcome.
        Borsh.Data memory borshData = Borsh.from(proofData);
        ProofDecoder.FullOutcomeProof memory fullOutcomeProof = borshData.decodeFullOutcomeProof();
        require(borshData.finished(), 'Argument should be exact borsh serialization');

        bytes32 receiptId = fullOutcomeProof.outcome_proof.outcome_with_id.outcome.receipt_ids[0];
        require(!usedEvents_[receiptId], 'The burn event cannot be reused');

        if (isUsing) {
            usedEvents_[receiptId] = true;
        }

        require(
            keccak256(fullOutcomeProof.outcome_proof.outcome_with_id.outcome.executor_id) == keccak256(nearEthFactory),
            'Can only unlock tokens from the linked mintable fungible token on Near blockchain.'
        );

        result = fullOutcomeProof.outcome_proof.outcome_with_id.outcome.status;
        require(!result.failed, 'Cannot use failed execution outcome for unlocking the tokens.');
        require(!result.unknown, 'Cannot use unknown execution outcome for unlocking the tokens.');
    }

    function _viewProof(bytes memory proofData, uint64 proofBlockHeight)
        internal
        returns (ProofDecoder.ExecutionStatus memory result)
    {
        result = _parseProof(proofData, proofBlockHeight, false);
    }

    function _useProof(bytes memory proofData, uint64 proofBlockHeight)
        internal
        returns (ProofDecoder.ExecutionStatus memory result)
    {
        result = _parseProof(proofData, proofBlockHeight, true);
    }
}
