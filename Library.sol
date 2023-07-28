pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    
    string[] public availableBooks;
    address[] public borrowers;

    mapping(address => bool) uniqueBorrowers;
    //0 means book has never been added to the library, 1 means that all books are currently borrowed
    mapping(string => uint) public availableCopies;
    mapping(address => mapping(string => bool)) public borrowerToBook;

    modifier isAvailable(string memory _title) {
        require(availableCopies[_title] > 1, "No copy currently available!");
        _;
    }

    modifier alreadyBorrowed(address borrower, string memory _title) {
        require(borrowerToBook[borrower][_title], "Book not borrowed!");
        _;
    }

    modifier notBorrowed(address borrower, string memory _title) {
        require(!borrowerToBook[borrower][_title], "Book already borrowed");
        _;
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
        borrowerToBook[msg.sender][_title] = true;
        addUniqueBorrower(msg.sender);
    }

    function returnBook(string memory _title) external alreadyBorrowed(msg.sender, _title) {
        availableCopies[_title]++;
        borrowerToBook[msg.sender][_title] = false;
    }

    function addUniqueBorrower(address _address) private {
        if (uniqueBorrowers[_address] == false) {
            borrowers.push(_address);
            uniqueBorrowers[_address] = true;
        }
    }
}