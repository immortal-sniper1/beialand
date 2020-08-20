package com.beia_consult_international.solomon.controller;

import com.beia_consult_international.solomon.dto.UserDto;
import com.beia_consult_international.solomon.exception.WrongUserDetailsException;
import com.beia_consult_international.solomon.model.User;
import com.beia_consult_international.solomon.service.UserService;
import com.beia_consult_international.solomon.service.mapper.UserMapper;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/login")
    public UserDto login(@RequestParam String username, @RequestParam String password) {
        if(!userService.validUserDetails(username, password))
            throw new WrongUserDetailsException();
        return UserMapper.mapToDto(userService.findUserByUsername(username));
    }

    @PostMapping("/signUp")
    public Boolean signUp(@RequestBody UserDto userDto, @RequestParam String password) {
        System.out.println(userDto.toString());
        User user = UserMapper.mapToModel(userDto);
        if(userService.userExists(user)) {
            return false;
        }
        userService.save(user, password);
        return true;
    }
}
