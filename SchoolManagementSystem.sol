// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

contract School
{
    struct Student
    {
        uint studentRegNo;
        uint RollNo;
        string studentName;
        uint studentClass;
        uint contact;
        string residence;
        string gender;
    } 

    struct teacher
    {
        uint teacherRegNo;
        uint teacherId;
        string teacherName;
        string teacher_department;
        string teacherGrade;
    }

    struct class
    {
        uint classNo;
        string classTeacher;
        uint totalBoys;
        uint totalGirls;
        uint totalStudents;
    }

    struct Department{
        uint deptID;
        string departmentName;
        string departmentHead;
        uint totalTeacherinDepartment;
    }
    
    // mappings 
    mapping(uint => Student )StudentRegister;
    mapping(uint => teacher )teacherRegister;
    mapping(uint => class) classRecord; 
    mapping( string => teacher[] ) teacherGradeRecord;
    mapping( string => Department )allDepartmentRegister;
    
    //events 
    event studentCreated( string msg );
    event teacherAdmitted( string msg );
    event classCreated( string msg );

    // variables 
    uint public totalStudent;
    uint public totalTeachers;
    uint private allClasses;    
    address public director;

    // constructor
    constructor(){
        director = msg.sender;
    }

    // functions
    
    function RegisterStudent( string memory _studentName, uint8 _studentClass, uint _contact, 
                            string memory _residence, string calldata _gender  ) public
    {
        require( _studentClass > 0 || _studentClass <= 12 , "The Student class should be less than 13" );
        require(keccak256(abi.encodePacked( _gender )) == keccak256(abi.encodePacked("Male"))  || keccak256(abi.encodePacked( _gender )) == keccak256(abi.encodePacked("Female")) , "The Student class should be less than 13" );
        require( keccak256(abi.encodePacked( _studentName )) == keccak256(abi.encodePacked("")) , "Name is required");

        Student storage newStudent = StudentRegister[++totalStudent];
        
        newStudent.studentRegNo++;
        newStudent.RollNo++;
        newStudent.studentName = _studentName;
        newStudent.studentClass = _studentClass;
        newStudent.contact = _contact;
        newStudent.residence = _residence; 
        newStudent.gender = _gender;

        class storage classData = classRecord[_studentClass];
       
        if( keccak256(abi.encodePacked( _gender )) == keccak256(abi.encodePacked("Male")))
        {
            classData.totalBoys += 1;
        }
        
        if( keccak256(abi.encodePacked( _gender )) == keccak256(abi.encodePacked("Female")))
        {
            classData.totalGirls += 1;
        }    

        classData.totalStudents += 1;
        emit studentCreated("student created");
    }



    function createClass(uint classNo , string memory classTeacher) public
    {
        class storage classData = classRecord[ classNo ];
        classData.classNo = classNo ;
        classData.classTeacher = classTeacher ;
        emit classCreated("classCreated");
    }

    function AdmitTeacher(string memory teacher_name , string memory teacher_department, string memory _teacherGrade) public
    {
        totalTeachers +=1;
        teacher storage newTeacher = teacherRegister[totalTeachers];
        
        newTeacher.teacherRegNo = totalTeachers ;
        newTeacher.teacherId = totalTeachers;
        newTeacher.teacherName = teacher_name;
        newTeacher.teacher_department = teacher_department;
        newTeacher.teacherGrade = _teacherGrade;
        
        teacherGradeRecord[_teacherGrade].push(newTeacher);
        
        emit teacherAdmitted( "Teacher Admitted !!");    
    }

    function fetchDepartmentDetail( string memory _subject ) public view returns(Department memory ) {
        Department memory temp =  allDepartmentRegister[ _subject ];
        return temp;
    }

    function createPrinciple(string memory _subject) public 
    {
        Department memory temp =  allDepartmentRegister[_subject];
    } 

    function totalStudentInClass( uint _class ) public view returns(uint256)
    {
        require( _class > 0  || _class < 13 , "class should be less than 13");
        class memory classData = classRecord[ _class ];
        return classData.totalStudents;    
    }

    function totalBoysInClass( uint _class ) public view returns(uint256)
    {
        require( _class > 0  || _class < 13 , "class should be less than 13");
        class memory classData = classRecord[ _class ];
        return classData.totalBoys;    
    }

    function totalGirlsInClass( uint _class ) public view returns(uint256)
    {
        require( _class > 0  || _class < 13 , "class should be less than 13");
        class memory classData = classRecord[ _class ];
        return classData.totalGirls;    
    }

    function fetchTeacherGradeRecord(string memory _grade) public view returns(teacher [] memory){
        require( keccak256(abi.encodePacked( _grade )) == keccak256(abi.encodePacked("first")) || keccak256(abi.encodePacked( _grade )) == keccak256(abi.encodePacked("second")) || keccak256(abi.encodePacked( _grade )) == keccak256(abi.encodePacked("third")));
        return teacherGradeRecord[ _grade ];
    }
}