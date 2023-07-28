pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {

    string[] public availableBooks;
    address[] public borrowers;

    mapping(address => bool) uniqueBorrowers;
    //0 means book has never been added to the library, 1 means that all books are currently borrowed
    mapping(string => uint) private availableCopies;
    mapping(string => bool) private borrowerToBook;

    modifier isAvailable(string memory _title) {
        require(availableCopies[_title] > 1, "No copy currently available!");
        _;
    }

    modifier alreadyBorrowed(address _borrower, string memory _title) {
        require(borrowerToBook[_generateKey(borrower, _title)], "Book not borrowed!");
        _;
    }

    modifier notBorrowed(address _borrower, string memory _title) {
        require(!borrowerToBook[_generateKey(_borrower, _title)], "Book already borrowed");
        _;
    }

    function getAvailableCopies(string memory _title) external view returns (uint) {
        return availableCopies[_title] == 0 ? 0 : availableCopies[_title]-1;
    }

    function getBorrowerToBook(string memory _title) external view returns (bool) {
        return borrowerToBook[_generateKey(msg.sender, _title)];
    }

    function _generateKey(address _address, string memory _title) private pure returns (string memory) {
        return string(abi.encodePacked(_address, _title));
    }

    function addBooks(string memory _title, uint _copies) external onlyOwner {
        // require(_copies > 0 && _title != "");
        if (availableCopies[_title] < 1) {
            availableBooks.push(_title);
            availableCopies[_title]++;
        }
        availableCopies[_title] += _copies;
    }

    function borrowBook(string memory _title) external isAvailable(_title) notBorrowed(msg.sender, _title) {
        availableCopies[_title]--;
        borrowerToBook[_generateKey(msg.sender, _title)] = true;
        addUniqueBorrower(msg.sender);
    }

    function returnBook(string memory _title) external alreadyBorrowed(msg.sender, _title) {
        availableCopies[_title]++;
        borrowerToBook[_generateKey(msg.sender, _title)] = false;
    }

    function addUniqueBorrower(address _address) private {
        if (uniqueBorrowers[_address] == false) {
            borrowers.push(_address);
            uniqueBorrowers[_address] = true;
        }
    }
}